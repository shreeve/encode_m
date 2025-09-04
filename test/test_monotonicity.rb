#!/usr/bin/env ruby
# Monotonicity Property Test for EncodeM
# Verifies: For all x, y: (x < y) ⟺ (encode(x) < encode(y))

require_relative '../lib/encode_m'
require 'minitest/autorun'

class TestMonotonicity < Minitest::Test
  # Test with a comprehensive set of values
  TEST_VALUES = [
    # Negative values
    -1_000_000_000, -999_999, -10_000, -1000, -999, -100, -99, -10, -9, -5, -1,
    # Zero
    0,
    # Positive values
    1, 5, 9, 10, 99, 100, 999, 1000, 10_000, 999_999, 1_000_000_000,
    # Edge cases
    -2**31, -2**16, -256, -128, 127, 255, 2**16-1, 2**31-1,
    # Random samples
    -123456, -42, 42, 123456, 9876543
  ]

  def test_strict_monotonicity
    # Test all pairs to ensure ordering is preserved
    TEST_VALUES.each_with_index do |x, i|
      TEST_VALUES.each_with_index do |y, j|
        next if i == j  # Skip comparing with self

        # Encode both values
        encoded_x = EncodeM.new(x).to_encoded
        encoded_y = EncodeM.new(y).to_encoded

        # Check monotonicity property
        numeric_comparison = x <=> y
        byte_comparison = encoded_x <=> encoded_y

        assert_equal numeric_comparison, byte_comparison,
          "Monotonicity violated: #{x} <=> #{y} = #{numeric_comparison}, " \
          "but encode(#{x}) <=> encode(#{y}) = #{byte_comparison}\n" \
          "Bytes: #{encoded_x.bytes.map{|b| '%02X' % b}.join(' ')} vs " \
          "#{encoded_y.bytes.map{|b| '%02X' % b}.join(' ')}"
      end
    end
  end

  def test_random_monotonicity
    # Test with 1000 random pairs
    1000.times do
      x = rand(-1_000_000..1_000_000)
      y = rand(-1_000_000..1_000_000)

      encoded_x = EncodeM.new(x).to_encoded
      encoded_y = EncodeM.new(y).to_encoded

      numeric_comparison = x <=> y
      byte_comparison = encoded_x <=> encoded_y

      assert_equal numeric_comparison, byte_comparison,
        "Random monotonicity failed: #{x} <=> #{y}"
    end
  end

  def test_adjacent_values
    # Test that adjacent values maintain proper ordering
    (-100..100).each_cons(2) do |x, y|
      encoded_x = EncodeM.new(x).to_encoded
      encoded_y = EncodeM.new(y).to_encoded

      assert encoded_x < encoded_y,
        "Adjacent values failed: #{x} should be < #{y} in encoded form"
    end
  end

  def test_round_trip_preservation
    # Ensure round-trip doesn't affect ordering
    TEST_VALUES.each do |value|
      encoded = EncodeM.new(value).to_encoded
      decoded = EncodeM.decode(encoded)

      assert_equal value, decoded,
        "Round-trip failed for #{value}: got #{decoded}"
    end
  end

  def test_zero_special_case
    # Zero should be between all negatives and all positives
    zero_encoded = EncodeM.new(0).to_encoded

    # All negatives should be less than zero
    [-1, -10, -100, -1000].each do |neg|
      neg_encoded = EncodeM.new(neg).to_encoded
      assert neg_encoded < zero_encoded,
        "Negative #{neg} should be < 0 in encoded form"
    end

    # All positives should be greater than zero
    [1, 10, 100, 1000].each do |pos|
      pos_encoded = EncodeM.new(pos).to_encoded
      assert pos_encoded > zero_encoded,
        "Positive #{pos} should be > 0 in encoded form"
    end
  end

  def test_negative_ordering
    # Larger magnitude negatives should have smaller byte values
    values = [-1000, -100, -10, -1]
    encoded = values.map { |v| EncodeM.new(v).to_encoded }

    assert_equal encoded, encoded.sort,
      "Negative values not properly ordered"
  end

  def test_positive_ordering
    # Larger positives should have larger byte values
    values = [1, 10, 100, 1000]
    encoded = values.map { |v| EncodeM.new(v).to_encoded }

    assert_equal encoded, encoded.sort,
      "Positive values not properly ordered"
  end
end

if __FILE__ == $0
  # Run with verbose output when executed directly
  require 'minitest/reporters'
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

  puts "=" * 60
  puts "EncodeM Monotonicity Property Test"
  puts "Verifying: ∀ x,y: (x < y) ⟺ (encode(x) < encode(y))"
  puts "=" * 60
  puts
end
