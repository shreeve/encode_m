require 'minitest/autorun'
require 'encode_m'

class TestEncodeM < Minitest::Test
  def test_initialization
    assert_equal 42, EncodeM.new(42).to_i
    assert_equal 3.14, EncodeM.new(3.14).to_f.round(2)
    assert_equal 100, EncodeM.new("100").to_i
  end
  
  def test_m_convenience_method
    # Test the M() global method - honoring M language style
    assert_equal 42, M(42).to_i
    assert_equal 10, M(10).to_i
  end
  
  def test_arithmetic
    a = EncodeM.new(10)
    b = EncodeM.new(3)
    
    assert_equal 13, (a + b).to_i
    assert_equal 7, (a - b).to_i
    assert_equal 30, (a * b).to_i
    assert_in_delta 3.33, (a / b).to_f, 0.01
    assert_equal 1000, (a ** b).to_i
  end
  
  def test_comparison
    a = EncodeM.new(10)
    b = EncodeM.new(20)
    c = EncodeM.new(10)
    
    assert a < b
    assert b > a
    assert a == c
    assert a <= c
    assert b >= a
  end
  
  def test_m_language_sorting
    # The key M language feature: encoded forms maintain sort order
    numbers = [5, -10, 0, 100, -5, 50, 1000].map { |n| EncodeM.new(n) }
    sorted = numbers.sort_by(&:encoded)
    expected = [-10, -5, 0, 5, 50, 100, 1000]
    
    assert_equal expected, sorted.map(&:to_i)
  end
  
  def test_edge_cases
    assert_equal 0, EncodeM.new(0).to_i
    assert EncodeM.new(-42).negative?
    assert EncodeM.new(42).positive?
    assert EncodeM.new(0).zero?
  end
  
  def test_large_numbers
    # M language traditionally handles up to 10^9 efficiently
    large = EncodeM.new(999_999_999)
    assert_equal 999_999_999, large.to_i
    
    larger = EncodeM.new(1_000_000_000)
    assert large < larger
  end
  
  def test_encoding_decoding
    # Test M encoding/decoding cycle
    original = 42
    m_num = EncodeM.new(original)
    encoded = m_num.to_encoded
    decoded = EncodeM.decode(encoded)
    
    assert_equal original, decoded
  end
  
  def test_database_sorting
    # Verify the main feature: byte-wise sorting matches numeric sorting
    values = [-1000, -1, 0, 1, 10, 100, 1000]
    encoded_values = values.map { |v| [v, EncodeM.new(v).to_encoded] }
    
    # Sort by encoded bytes
    byte_sorted = encoded_values.sort_by { |_, encoded| encoded }
    
    # Verify order is preserved
    assert_equal values, byte_sorted.map(&:first)
  end
end
