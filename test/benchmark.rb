#!/usr/bin/env ruby

require 'benchmark/ips'
require 'bigdecimal'
require_relative '../lib/encode_m'

puts "EncodeM Performance Benchmark"
puts "="*50

# Test values
small_int = 42
large_int = 999_999_999
float_val = 3.14159

Benchmark.ips do |x|
  x.report("Integer arithmetic") do
    a = small_int + small_int
    b = a * 2
    c = b - 10
  end

  x.report("Float arithmetic") do
    a = float_val + float_val
    b = a * 2.0
    c = b - 1.0
  end

  x.report("BigDecimal arithmetic") do
    bd = BigDecimal(float_val.to_s)
    a = bd + bd
    b = a * BigDecimal("2")
    c = b - BigDecimal("1")
  end

  x.report("EncodeM arithmetic") do
    em = M(float_val)
    a = em + em
    b = a * M(2)
    c = b - M(1)
  end

  x.compare!
end

puts "\nSorting Performance (1000 numbers)"
puts "="*50

numbers = 1000.times.map { rand(-1000..1000) }

Benchmark.ips do |x|
  x.report("Integer sort") do
    numbers.sort
  end

  x.report("EncodeM byte sort") do
    encoded = numbers.map { |n| M(n).to_encoded }
    encoded.sort
  end

  x.report("EncodeM object sort") do
    m_numbers = numbers.map { |n| M(n) }
    m_numbers.sort
  end

  x.compare!
end
