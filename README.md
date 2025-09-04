# EncodeM

[![Gem Version](https://badge.fury.io/rb/encode_m.svg)](https://badge.fury.io/rb/encode_m)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Bringing the power of M language (MUMPS) numeric encoding to Ruby. Based on YottaDB/GT.M's 40-year production-tested algorithm.

## About the M Language Heritage

The M language (formerly MUMPS - Massachusetts General Hospital Utility Multi-Programming System) has been powering critical healthcare and financial systems since 1966. Epic (70% of US hospitals), the VA's VistA, and numerous banking systems run on M. This gem extracts one of M's most clever innovations: a numeric encoding that maintains sort order in byte form.

## Key Features

- **Sortable Byte Encoding**: Numbers encode to bytes that sort correctly without decoding
- **Production-Tested**: Algorithm proven in healthcare and finance for 40 years
- **Optimized for Real Use**: Special handling for common number ranges
- **Memory Efficient**: Compact representation, especially for small integers
- **Database-Friendly**: Perfect for indexing and byte-wise comparisons

## Installation

Add to your Gemfile:

```ruby
gem 'encode_m'
```

Or install directly:

```bash
$ gem install encode_m
```

## Usage

```ruby
require 'encode_m'

# Create numbers using the M() convenience method
a = M(42)
b = M(3.14)
c = M(-100)

# Arithmetic works naturally
sum = a + b        # => EncodeM(45.14)
product = a * M(2) # => EncodeM(84)

# The magic: encoded bytes sort correctly!
numbers = [M(5), M(-10), M(0), M(100), M(-5)]
sorted = numbers.sort  # Correctly sorted: -10, -5, 0, 5, 100

# Perfect for databases - compare without decoding
encoded_a = a.to_encoded  # => "\x40\x42"
encoded_b = b.to_encoded  # => "\x40\x03\x14"
encoded_a < encoded_b      # => false (42 > 3.14)

# Decode back to numbers
original = EncodeM.decode(encoded_a)  # => 42
```

## Why EncodeM?

Traditional numeric types force compromises:

| Type | Speed | Precision | Memory | Sortable as Bytes |
|------|-------|-----------|---------|-------------------|
| Integer | ⚡️ Fast | ✅ Exact | ✅ Efficient | ❌ No |
| Float | ⚡️ Fast | ❌ Limited | ✅ Efficient | ❌ No |
| BigDecimal | ❌ Slow | ✅ Unlimited | ❌ Heavy | ❌ No |
| **EncodeM** | ✅ Good | ✅ 18 digits | ✅ Efficient | ✅ **Yes!** |

EncodeM's unique advantage: encoded bytes maintain sort order, enabling:
- Direct byte comparison in databases
- Efficient indexing without decoding
- Fast range queries on encoded data

## Performance Characteristics

Based on the M language's real-world patterns:
- **Small integers (< 10)**: 2 bytes
- **Common range (-999 to 999)**: 2-3 bytes
- **Typical numbers (-10^9 to 10^9)**: 4-6 bytes
- **Sortable without decoding**: Massive performance win for databases

## Use Cases

- **Financial Systems**: More precision than Float, faster than BigDecimal
- **Database Indexing**: Sort encoded bytes directly
- **Healthcare Systems**: Proven in Epic, VistA, and other M-based systems
- **High-Volume Processing**: Efficient encoding for billions of records
- **Cross-System Integration**: Compatible with M language databases

## Attribution

This gem implements the numeric encoding algorithm from YottaDB and GT.M, which has been proven in production systems for nearly 40 years. 

**Algorithm Credit**:
- Original design: Greystone Technology Corporation (1980s)
- Current implementations: [YottaDB](https://gitlab.com/YottaDB/DB/YDB) (AGPLv3) and GT.M
- Production proven in Epic, VistA, and Profile banking systems

**Ruby Implementation**:
- Author: Steve Shreeve (steve.shreeve@gmail.com)
- Implementation assistance: Claude Opus 4.1 (Anthropic)
- This is a clean-room reimplementation of the algorithm, not a code port

## Development

After checking out the repo, run:

```bash
bundle install
rake test
```

### Running Benchmarks

The gem includes two benchmark scripts in the `test/` directory:

```bash
# Performance benchmark - arithmetic and sorting operations
ruby -I lib test/benchmark.rb

# Database use case benchmark - demonstrates key benefits
ruby -I lib test/benchmark_database.rb
```

Note: You may need to install `bigdecimal` gem for Ruby 3.4+:
```bash
gem install bigdecimal
```

### Building and Installing

To install this gem locally:

```bash
bundle exec rake install
```

To release a new version:

```bash
bundle exec rake release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shreeve/encode_m.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Acknowledgments

Special thanks to:
- The YottaDB team for maintaining and open-sourcing this technology
- The M language community for decades of innovation in database technology
- Anthropic's Claude Opus 4.1 for assistance with the Ruby implementation
