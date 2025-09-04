require 'minitest/autorun'
require 'encode_m'

class TestEncodeString < Minitest::Test
  def test_string_initialization
    str = M("Hello")
    assert_instance_of EncodeM::String, str
    assert_equal "Hello", str.to_s
    assert_equal "Hello", str.value
  end
  
  def test_empty_string
    empty = M("")
    assert_instance_of EncodeM::String, empty
    assert_equal "", empty.to_s
    assert empty.empty?
    assert_equal 0, empty.length
  end
  
  def test_string_encoding
    # String should start with 0xFF
    str = M("Test")
    encoded = str.to_encoded
    assert_equal 0xFF, encoded.bytes.first
    
    # Empty string is just 0xFF
    empty = M("")
    assert_equal [0xFF].pack('C*'), empty.to_encoded
  end
  
  def test_special_character_escaping
    # Test null byte escaping
    str_with_null = M("Test\x00Null")
    encoded = str_with_null.to_encoded.bytes
    
    # Should have 0xFF prefix, then escaped null
    assert_equal 0xFF, encoded[0]
    # Find the escaped null (0x01 0xFF)
    assert encoded.include?(0x01), "Should include escape byte"
    
    # Test 0x01 byte escaping
    str_with_one = M("Test\x01One")
    encoded = str_with_one.to_encoded.bytes
    assert encoded.include?(0x01), "Should include escape byte"
  end
  
  def test_string_comparison
    a = M("Apple")
    b = M("Banana")
    c = M("Apple")
    
    assert a < b
    assert b > a
    assert a == c
    assert a <= c
    assert b >= a
  end
  
  def test_string_vs_numeric_comparison
    # In M language, all numbers sort before all strings
    num = M(999999)
    str = EncodeM::String.new("0")  # Force "0" to be a string, not parsed as number
    
    assert num < str
    assert str > num
  end
  
  def test_string_decoding
    original = "Hello, World!"
    encoded = M(original).to_encoded
    decoded = EncodeM.decode(encoded)
    
    assert_equal original, decoded
  end
  
  def test_string_with_unicode
    unicode_str = "Hello 世界 🌍"
    m_str = M(unicode_str)
    encoded = m_str.to_encoded
    decoded = EncodeM.decode(encoded)
    
    assert_equal unicode_str, decoded
  end
  
  def test_string_round_trip
    test_strings = [
      "",
      "a",
      "Hello",
      "With spaces",
      "Special!@#$%^&*()",
      "Line\nBreak",
      "Tab\tCharacter",
      "Null\x00Byte",
      "One\x01Byte",
      "Mixed\x00\x01Bytes"
    ]
    
    test_strings.each do |str|
      encoded = M(str).to_encoded
      decoded = EncodeM.decode(encoded)
      assert_equal str, decoded, "Failed round-trip for: #{str.inspect}"
    end
  end
  
  def test_string_sorting
    strings = ["zebra", "apple", "banana", "", "Apple", "ZEBRA"]
    m_strings = strings.map { |s| M(s) }
    
    sorted = m_strings.sort
    sorted_values = sorted.map(&:to_s)
    
    # Should maintain byte-wise sort order
    expected = strings.sort
    assert_equal expected, sorted_values
  end
  
  def test_nil_becomes_empty_string
    m_nil = M(nil)
    assert_instance_of EncodeM::String, m_nil
    assert_equal "", m_nil.to_s
    assert_equal M(""), m_nil
  end
end
