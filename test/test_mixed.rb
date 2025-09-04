require 'minitest/autorun'
require 'encode_m'

class TestMixedTypes < Minitest::Test
  def test_m_function_polymorphism
    # M() should handle all types correctly
    num = M(42)
    str = M("hello")
    comp = M("users", 42)
    
    assert_instance_of EncodeM::Numeric, num
    assert_instance_of EncodeM::String, str
    assert_instance_of EncodeM::Composite, comp
  end
  
  def test_mixed_type_sorting
    # M language order: all numbers < all strings
    items = [
      EncodeM::String.new("zero"),  # String (not numeric)
      M(1000000),     # Large number
      M(-1000000),    # Large negative
      M(""),          # Empty string
      M(0),           # Zero
      M("zebra"),     # String
      M(-1),          # Negative number
      M(1),           # Positive number
    ]
    
    sorted = items.sort_by(&:to_encoded)
    
    # Expected order: -1000000, -1, 0, 1, 1000000, "", "zebra", "zero"
    assert_equal -1000000, sorted[0].value
    assert_equal -1, sorted[1].value
    assert_equal 0, sorted[2].value
    assert_equal 1, sorted[3].value
    assert_equal 1000000, sorted[4].value
    assert_equal "", sorted[5].value
    assert_equal "zebra", sorted[6].value  # "zebra" < "zero" alphabetically
    assert_equal "zero", sorted[7].value
  end
  
  def test_composite_with_all_types
    comp = M(
      42,                # Integer
      -3.14,             # Float (becomes integer)
      "string",          # String
      0,                 # Zero
      "",                # Empty string
      -1                 # Negative
    )
    
    assert_equal [42, -3, "string", 0, "", -1], comp.to_a
  end
  
  def test_real_world_example
    # Simulate a real database key structure
    keys = [
      M("users", 100, "profile", "name"),
      M("users", 100, "profile", "email"),
      M("users", 99, "profile", "name"),
      M("users", 100, "posts", 1),
      M("users", 100, "posts", 2),
      M("groups", 1, "members", 100),
      M("groups", 1, "members", 99),
    ]
    
    sorted = keys.sort
    
    # Groups should come before users
    assert sorted[0].to_a[0] == "groups"
    assert sorted[-1].to_a[0] == "users"
    
    # Within users/100, posts should come before profile
    user_100 = sorted.select { |k| k.to_a[0] == "users" && k.to_a[1] == 100 }
    assert user_100.first.to_a[2] == "posts"
  end
  
  def test_steve_example
    # The example from the conversation
    steve = M("Steve", 2025, "Fun", -3, "")
    
    assert_instance_of EncodeM::Composite, steve
    assert_equal ["Steve", 2025, "Fun", -3, ""], steve.to_a
    
    # Should encode/decode correctly
    encoded = steve.to_encoded
    decoded = EncodeM.decode_composite(encoded)
    assert_equal ["Steve", 2025, "Fun", -3, ""], decoded
  end
  
  def test_global_array_simulation
    # Simulate M language global arrays like ^DATA("users",id,"email")
    data = {}
    
    # Store some data
    data[M("users", 1, "email").to_encoded] = "alice@example.com"
    data[M("users", 2, "email").to_encoded] = "bob@example.com"
    data[M("users", 1, "name").to_encoded] = "Alice"
    data[M("users", 2, "name").to_encoded] = "Bob"
    data[M("posts", 1, "author").to_encoded] = "1"
    data[M("posts", 1, "title").to_encoded] = "Hello World"
    
    # Keys should sort hierarchically
    sorted_keys = data.keys.sort
    decoded_keys = sorted_keys.map { |k| EncodeM.decode_composite(k) }
    
    # Posts should come before users
    assert decoded_keys.first[0] == "posts"
    
    # Within users, ID 1 should come before ID 2
    user_keys = decoded_keys.select { |k| k[0] == "users" }
    assert user_keys[0][1] == 1
    assert user_keys[2][1] == 2
  end
  
  def test_type_coercion
    # Test that various Ruby types get coerced properly
    assert_equal 42, M(42).value
    assert_equal 42, M(42.0).value
    assert_equal 42, M(42.7).value  # Truncates
    assert_equal 42, M("42").value  # Numeric strings auto-parse to numbers
    assert_equal "test", M("test").value  # Non-numeric strings stay as strings
    assert_equal "", M(nil).value
  end
  
  def test_encode_decode_symmetry
    # Everything that encodes should decode back to equivalent value
    test_values = [
      0, 1, -1, 42, -42, 1000, -1000,
      "", "a", "test", "with spaces", "unicode 世界",
      ["composite", 1],
      ["multi", "part", 123, "key"],
      ["with", nil, "nil"]
    ]
    
    test_values.each do |val|
      if val.is_a?(Array)
        encoded = M(*val).to_encoded
        decoded = EncodeM.decode_composite(encoded)
        # nil becomes "" in composites
        expected = val.map { |v| v.nil? ? "" : v }
        assert_equal expected, decoded
      else
        encoded = M(val).to_encoded
        decoded = EncodeM.decode(encoded)
        expected = val.nil? ? "" : val
        assert_equal expected, decoded
      end
    end
  end
  
  def test_byte_length_efficiency
    # Verify that common values are space-efficient
    assert_equal 2, M(5).to_encoded.length      # Small positive
    assert_equal 3, M(-5).to_encoded.length     # Small negative (with terminator)
    assert_equal 1, M(0).to_encoded.length      # Zero is just one byte
    assert_equal 1, M("").to_encoded.length     # Empty string is just 0xFF
    
    # Composite with small values should be compact
    comp = M(2025, 1, 15)  # Date
    assert comp.to_encoded.length < 10, "Date should be compact"
  end
end
