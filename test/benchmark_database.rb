#!/usr/bin/env ruby

require 'benchmark/ips'
require 'bigdecimal'
require_relative '../lib/encode_m'

puts "EncodeM Database Use Case Benchmark"
puts "=" * 60
puts "Simulating database operations where values are stored as bytes"
puts "and need to be sorted/compared WITHOUT decoding"
puts

# Generate test data - mix of positive, negative, and decimal numbers
test_numbers = 1000.times.map { rand(-10000.0..10000.0).round(2) }

puts "Test: Sorting 1000 numbers stored as bytes (database scenario)"
puts "-" * 60

# Prepare different storage formats
float_bytes = test_numbers.map { |n| [n.to_f].pack('E') }  # 8 bytes each
bigdecimal_strings = test_numbers.map { |n| n.to_s }       # Variable length strings
encode_m_bytes = test_numbers.map { |n| M(n).to_encoded }   # EncodeM encoded bytes

Benchmark.ips do |x|
  x.report("Float (decode->sort->encode)") do
    # Must decode, sort, then re-encode
    decoded = float_bytes.map { |b| b.unpack('E')[0] }
    sorted = decoded.sort
    sorted.map { |n| [n].pack('E') }
  end

  x.report("BigDecimal (parse->sort->string)") do
    # Must parse strings, sort, then convert back
    decoded = bigdecimal_strings.map { |s| BigDecimal(s) }
    sorted = decoded.sort
    sorted.map(&:to_s)
  end

  x.report("EncodeM (direct byte sort!)") do
    # Just sort the bytes directly - no decoding needed!
    encode_m_bytes.sort
  end

  x.compare!
end

puts "\nTest: Range queries (find values between -100 and 100)"
puts "-" * 60

# Pre-sort for range queries
sorted_floats = test_numbers.sort
sorted_encode_m = encode_m_bytes.sort
lower_bound_em = M(-100).to_encoded
upper_bound_em = M(100).to_encoded

Benchmark.ips do |x|
  x.report("Float (decode all & filter)") do
    float_bytes.select { |b|
      val = b.unpack('E')[0]
      val >= -100 && val <= 100
    }
  end

  x.report("EncodeM (direct byte comparison!)") do
    sorted_encode_m.select { |b|
      b >= lower_bound_em && b <= upper_bound_em
    }
  end

  x.compare!
end

puts "\nDatabase Index Benefits:"
puts "-" * 60
puts "✅ EncodeM: Can use byte-wise comparison in B-trees"
puts "✅ EncodeM: No deserialization needed for index operations"
puts "✅ EncodeM: Compact storage (2-6 bytes for common values)"
puts "❌ Float: Must deserialize for every comparison"
puts "❌ BigDecimal: String comparison doesn't preserve numeric order"
puts

# Show storage efficiency
puts "Storage Efficiency Example:"
puts "-" * 60
[1, 42, 100, 1000, 1000000].each do |n|
  float_size = [n.to_f].pack('E').bytesize
  bigdecimal_size = n.to_s.bytesize
  encode_m_size = M(n).to_encoded.bytesize

  puts "Number #{n}:"
  puts "  Float:      #{float_size} bytes"
  puts "  BigDecimal: #{bigdecimal_size} bytes (as string)"
  puts "  EncodeM:    #{encode_m_size} bytes"
end
