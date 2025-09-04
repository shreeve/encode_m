require 'minitest/autorun'
require 'encode_m'

class TestEncodeComposite < Minitest::Test
  def test_composite_initialization
    comp = M("users", 42, "email")
    assert_instance_of EncodeM::Composite, comp
    assert_equal ["users", 42, "email"], comp.to_a
    assert_equal 3, comp.length
  end
  
  def test_composite_with_mixed_types
    comp = M("Steve", 2025, "Fun", -3, "")
    assert_equal ["Steve", 2025, "Fun", -3, ""], comp.to_a
    assert_equal 5, comp.length
  end
  
  def test_composite_encoding
    comp = M("test", 123)
    encoded = comp.to_encoded.bytes
    
    # Should contain: 0xFF "test" 0x00 [123 encoded]
    assert encoded.include?(0xFF), "Should have string prefix"
    assert encoded.include?(0x00), "Should have delimiter"
  end
  
  def test_composite_component_access
    comp = M("a", 1, "b", 2)
    
    assert_equal "a", comp[0].value
    assert_equal 1, comp[1].value
    assert_equal "b", comp[2].value
    assert_equal 2, comp[3].value
    assert_nil comp[4]
  end
  
  def test_composite_comparison
    a = M("users", 1)
    b = M("users", 2)
    c = M("users", 1)
    d = M("accounts", 1)
    
    assert a < b, "Same prefix, smaller number should sort first"
    assert a == c, "Identical composites should be equal"
    assert d < a, "accounts < users alphabetically"
  end
  
  def test_hierarchical_sorting
    # Composite keys should maintain hierarchical sort order
    keys = [
      M("users", 10, "name"),
      M("users", 2, "email"),
      M("users", 2, "name"),
      M("users", 1),
      M("users"),
      M("accounts", 100),
      M("zones", 1)
    ]
    
    sorted = keys.sort
    
    # Expected order:
    # accounts/100 < users < users/1 < users/2/email < users/2/name < users/10/name < zones/1
    assert_equal M("accounts", 100), sorted[0]
    assert_equal M("users"), sorted[1]
    assert_equal M("users", 1), sorted[2]
    assert_equal M("users", 2, "email"), sorted[3]
    assert_equal M("users", 2, "name"), sorted[4]
    assert_equal M("users", 10, "name"), sorted[5]
    assert_equal M("zones", 1), sorted[6]
  end
  
  def test_composite_with_empty_strings
    comp = M("", 42, "", "test", "")
    assert_equal ["", 42, "", "test", ""], comp.to_a
    
    encoded = comp.to_encoded
    decoded = EncodeM.decode_composite(encoded)
    
    assert_equal ["", 42, "", "test", ""], decoded
  end
  
  def test_composite_decoding
    original = ["test", 123, "nested", -45, ""]
    comp = M(*original)
    encoded = comp.to_encoded
    decoded = EncodeM.decode_composite(encoded)
    
    assert_equal original, decoded
  end
  
  def test_date_as_composite
    # Common pattern: year/month/day/id
    date1 = M(2025, 1, 15, 1001)
    date2 = M(2025, 1, 15, 1002)
    date3 = M(2025, 1, 16, 1001)
    date4 = M(2024, 12, 31, 9999)
    
    # Should sort chronologically
    dates = [date3, date1, date4, date2].sort
    assert_equal date4, dates[0]  # 2024-12-31
    assert_equal date1, dates[1]  # 2025-01-15 #1001
    assert_equal date2, dates[2]  # 2025-01-15 #1002
    assert_equal date3, dates[3]  # 2025-01-16
  end
  
  def test_database_key_pattern
    # Simulate database composite keys
    user_email = M("users", 42, "attributes", "email")
    user_name = M("users", 42, "attributes", "name")
    user_posts = M("users", 42, "posts", 1)
    
    # All user 42's data should sort together
    keys = [user_posts, user_email, user_name].sort
    assert_equal user_email, keys[0]
    assert_equal user_name, keys[1]
    assert_equal user_posts, keys[2]
  end
  
  def test_single_component_composite
    # Single component should work but probably use M(value) directly
    comp = EncodeM::Composite.new("single")
    assert_instance_of EncodeM::Composite, comp
    assert_equal ["single"], comp.to_a
  end
  
  def test_composite_with_nil
    # nil should become empty string
    comp = M("test", nil, 42)
    assert_equal ["test", "", 42], comp.to_a
  end
  
  def test_nested_composite_not_allowed
    # Composites should not nest - they should be flattened
    assert_raises(ArgumentError) do
      inner = M("a", "b")
      M("outer", inner)
    end
  end
  
  def test_numbers_sort_before_strings_in_composite
    # Even in composite, number components sort before string components
    a = M(999, "a")  # number, string
    b = M("0", "a")   # string, string
    
    assert a < b, "Composite with number first should sort before string"
  end
  
  def test_composite_round_trip
    test_cases = [
      ["single"],
      ["users", 42],
      ["a", "b", "c"],
      [1, 2, 3],
      ["mixed", 123, "types", -45, ""],
      ["unicode", "世界", 42, "🌍"],
      ["special", "with\x00null", "and\x01one"]
    ]
    
    test_cases.each do |components|
      comp = M(*components)
      encoded = comp.to_encoded
      decoded = EncodeM.decode_composite(encoded)
      assert_equal components, decoded, "Failed round-trip for: #{components.inspect}"
    end
  end
  
  def test_empty_composite_not_allowed
    assert_raises(ArgumentError) do
      EncodeM::Composite.new
    end
  end
end
