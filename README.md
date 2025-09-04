# EncodeM

[![Gem Version](https://badge.fury.io/rb/encode_m.svg)](https://badge.fury.io/rb/encode_m)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**🎉 Version 3.0: Complete M language subscript encoding - numbers, strings, and composite keys!**

Bringing the power of M language (MUMPS) subscript encoding to Ruby. Build hierarchical database keys like `M("users", 42, "email")` with perfect sort order. Based on YottaDB/GT.M's 40-year production-tested algorithm.

## Why You Should Use EncodeM

**Version 3.0 brings complete M language subscript support!** Not just numbers anymore - now you can encode strings and build powerful composite keys for hierarchical data structures.

If you're building anything that stores data in a database or key-value store, EncodeM is a game-changer. The magic is simple but powerful: when you encode values with EncodeM, the resulting byte strings maintain perfect sort order. This means your database can compare and sort **without ever decoding** - just pure byte comparison like strcmp().

### What's New in v3.0:
- **String encoding**: Strings sort correctly after all numbers
- **Composite keys**: Build hierarchical keys like `M("users", 42, "profile", "email")`
- **Full M compatibility**: Generate YottaDB/GT.M compatible subscripts
- **Mixed types**: Combine numbers, strings, and more in a single key

Imagine building a user database where `M("users", userId, "posts", postId)` creates perfectly sortable hierarchical keys. Or time-series data with `M(2025, 1, 15, sensorId, "temperature")`. The encoding ensures all components sort correctly - numbers before strings, maintaining hierarchical order.

This is production-tested technology - literally the same encoding that's been processing medical records and financial transactions since the 1980s in YottaDB/GT.M systems. Epic (70% of US hospitals) and VistA use this exact algorithm for their global arrays. Drop it in, encode your data, and watch your database operations get faster.

## About the M Language Heritage

The M language (formerly MUMPS - Massachusetts General Hospital Utility Multi-Programming System) has been powering critical healthcare and financial systems since 1966. Epic (70% of US hospitals), the VA's VistA, and numerous banking systems run on M. This gem extracts one of M's most clever innovations: a numeric encoding that maintains sort order in byte form.

## Key Features

- **Complete M Language Support**: Numbers, strings, and composite keys
- **Sortable Byte Encoding**: All types encode to bytes that sort correctly without decoding
- **Hierarchical Keys**: Build multi-component database keys with perfect sort order
- **Production-Tested**: Algorithm proven in healthcare and finance for 40 years
- **YottaDB Compatible**: Generate valid YottaDB/GT.M subscripts
- **Memory Efficient**: Compact representation for all data types
- **Database-Friendly**: Perfect for B-tree indexes and key-value stores

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

### Numbers (Classic M encoding)
```ruby
require 'encode_m'

# Create numbers using the M() convenience method
a = M(42)
b = M(3.14)      # Floats are truncated to integers
c = M(-100)

# Arithmetic works naturally
sum = a + b        # => M(45)
product = a * M(2) # => M(84)

# The magic: encoded bytes sort correctly!
numbers = [M(5), M(-10), M(0), M(100), M(-5)]
sorted = numbers.sort  # Correctly sorted: -10, -5, 0, 5, 100

# Perfect for databases - compare without decoding
encoded_a = a.to_encoded  # => "\xBD\x2B"
encoded_b = b.to_encoded  # => "\xBC\x04"
encoded_a < encoded_b      # => false (42 > 3)
```

### Strings (New in v3.0!)
```ruby
# Encode strings - they sort after all numbers
name = M("Alice")
empty = M("")        # Empty string

# M language ordering: all numbers < all strings
M(999999) < M("0")   # => true

# String comparison maintains byte order
M("apple") < M("banana")  # => true
```

### Composite Keys (New in v3.0!)
```ruby
# Build hierarchical database keys
user_email = M("users", 42, "email")
user_name = M("users", 42, "name")
user_post = M("users", 42, "posts", 1)

# Perfect for time-series data
event = M(2025, 1, 15, 14, 30, "sensor_123", "temperature")

# Keys sort hierarchically
keys = [
  M("users", 2, "email"),
  M("users", 1, "name"),
  M("users", 1, "email"),
  M("users", 2, "name")
].sort
# Result order:
# ["users", 1, "email"]
# ["users", 1, "name"]
# ["users", 2, "email"]
# ["users", 2, "name"]

# Access components
user_email[0].value  # => "users"
user_email[1].value  # => 42
user_email.to_a      # => ["users", 42, "email"]

# Decode composite keys
encoded = user_email.to_encoded
decoded = EncodeM.decode_composite(encoded)  # => ["users", 42, "email"]
```

## Format Specification

EncodeM uses the complete M language subscript encoding that guarantees lexicographic byte ordering matches logical ordering for all data types.

### Encoding Structure

```
0x00      KEY_DELIMITER (separates components in composite keys)
0x01      STR_SUB_ESCAPE (escape byte for strings)
------- NEGATIVE NUMBERS (decreasing magnitude) -------
0x3B      -999,999,999 to -100,000,000 (9 digits)
0x3C      -99,999,999 to -10,000,000 (8 digits)
0x3D      -9,999,999 to -1,000,000 (7 digits)
0x3E      -999,999 to -100,000 (6 digits)
0x3F      -99,999 to -10,000 (5 digits)
0x40      -9,999 to -1,000 (4 digits)
0x41      -999 to -100 (3 digits)
0x42      -99 to -10 (2 digits)
0x43      -9 to -1 (1 digit)
------- ZERO -------
0x80      ZERO
------- POSITIVE NUMBERS (increasing magnitude) -------
0xBC      1 to 9 (1 digit)
0xBD      10 to 99 (2 digits)
0xBE      100 to 999 (3 digits)
0xBF      1,000 to 9,999 (4 digits)
0xC0      10,000 to 99,999 (5 digits)
0xC1      100,000 to 999,999 (6 digits)
0xC2      1,000,000 to 9,999,999 (7 digits)
0xC3      10,000,000 to 99,999,999 (8 digits)
0xC4      100,000,000 to 999,999,999 (9 digits)
------- STRINGS -------
0xFF      STR_SUB_PREFIX (all strings start with this)
```

### Numeric Encoding
- **First byte**: Determines sign and magnitude range
- **Following bytes**: Encode digit pairs (00-99) using lookup tables
- **Terminator**: Negative numbers end with `0xFF` to maintain sort order

### String Encoding
- **Prefix**: All strings start with `0xFF`
- **Content**: UTF-8 bytes of the string
- **Escaping**: Special bytes are escaped:
  - `0x00` → `0x01 0xFF`
  - `0x01` → `0x01 0xFE`

### Composite Key Encoding
- **Structure**: Components separated by `0x00` (KEY_DELIMITER)
- **Ordering**: Maintains hierarchical sort order
- **Example**: `M("users", 42)` → `[0xFF "users" 0x00 0xBD 0x2B]`

### Encoding Examples

| Value | Hex Bytes | Description |
|-------|-----------|-------------|
| -1000 | `3F FD EF FF` | 4-digit negative |
| -1 | `43 FB FF` | 1-digit negative |
| 0 | `80` | Zero (single byte) |
| 1 | `BC 02` | 1-digit positive |
| 42 | `BD 2B` | 2-digit positive |
| 1000 | `BF 0B 01` | 4-digit positive |
| "Hello" | `FF 48 65 6C 6C 6F` | String with 0xFF prefix |
| "" | `FF` | Empty string |
| ["users", 42] | `FF 75 73 65 72 73 00 BD 2B` | Composite key |
| [2025, 1, 15] | `BF 14 19 00 BC 02 00 BD 10` | Date as composite |

The encoding ensures:
- `bytewise_compare(encode(x), encode(y)) == logical_compare(x, y)`
- All numbers sort before all strings
- Composite keys maintain hierarchical order

## Ordering Guarantees

EncodeM provides **strict total ordering** across all encodable values:

- **Mathematical guarantee**: For any numbers x and y: `x < y ⟺ encode(x) < encode(y)` (bytewise)
- **Sign ordering**: All negatives < zero < all positives
- **Magnitude ordering**: Within each sign, magnitude determines order
- **Deterministic**: Same input always produces same output
- **Stable**: No special cases or exceptions

This enables direct byte comparison in databases without decoding.

## API Reference

### Core Methods

| Method | Description | Example |
|--------|-------------|---------|
| `M(value)` | Create encoded value | `M(42)`, `M("hello")` |
| `M(*values)` | Create composite key | `M("users", 42, "email")` |
| `EncodeM.new(value)` | Create encoded value | `EncodeM.new(42)` |
| `EncodeM.new(*values)` | Create composite key | `EncodeM.new("users", 42)` |
| `EncodeM.decode(bytes)` | Decode bytes to value | `EncodeM.decode("\xBD\x2B")` → `42` |
| `EncodeM.decode_composite(bytes)` | Decode composite key | Returns array of components |
| `#to_encoded` | Get encoded byte string | `M(42).to_encoded` → `"\xBD\x2B"` |
| `#value` | Get original value | `M(42).value` → `42` |
| `#to_a` | Get composite components | `M("a", 1).to_a` → `["a", 1]` |

### Arithmetic Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| `+` | Addition | `M(10) + M(5)` → `M(15)` |
| `-` | Subtraction | `M(10) - M(3)` → `M(7)` |
| `*` | Multiplication | `M(4) * M(3)` → `M(12)` |
| `/` | Division | `M(10) / M(2)` → `M(5)` |
| `**` | Exponentiation | `M(2) ** M(3)` → `M(8)` |

### Comparison Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| `<` | Less than | `M(5) < M(10)` → `true` |
| `>` | Greater than | `M(10) > M(5)` → `true` |
| `==` | Equality | `M(42) == M(42)` → `true` |
| `<=` | Less or equal | `M(5) <= M(5)` → `true` |
| `>=` | Greater or equal | `M(10) >= M(5)` → `true` |
| `<=>` | Spaceship operator | `M(5) <=> M(10)` → `-1` |

### Numeric Methods

| Method | Description | Example |
|--------|-------------|---------|
| `#to_i` | Convert to Integer | `M(3.14).to_i` → `3` |
| `#to_f` | Convert to Float | `M(42).to_f` → `42.0` |
| `#to_s` | Convert to String | `M(42).to_s` → `"42"` |
| `#zero?` | Check if zero | `M(0).zero?` → `true` |
| `#positive?` | Check if positive | `M(42).positive?` → `true` |
| `#negative?` | Check if negative | `M(-5).negative?` → `true` |

### String Methods

| Method | Description | Example |
|--------|-------------|---------|
| `#to_s` | Get string value | `M("hello").to_s` → `"hello"` |
| `#length` | String length | `M("hello").length` → `5` |
| `#empty?` | Check if empty | `M("").empty?` → `true` |

### Composite Methods

| Method | Description | Example |
|--------|-------------|---------|
| `#[]` | Access component | `M("a", 1)[0]` → `M("a")` |
| `#length` | Number of components | `M("a", 1, "b").length` → `3` |
| `#to_a` | Get all components | `M("a", 1).to_a` → `["a", 1]` |

## Edge Cases & Limits

### Supported Values
- **Integers**: Full range up to 18 digits
- **Floats**: Truncated to integers (M language design)
- **Strings**: Any UTF-8 string, with automatic escaping
- **Composite Keys**: Unlimited components of mixed types
- **Zero**: Handled as special case (single byte: `0x80`)
- **Negative numbers**: Full support with proper ordering
- **Nil**: Converted to empty string `""`

### Not Supported
- **NaN**: Raises `ArgumentError`
- **Infinity**: Raises `ArgumentError`
- **Non-numeric strings**: Raises `ArgumentError` unless parseable
- **nil**: Raises `ArgumentError`
- **Numbers > 18 digits**: Precision loss may occur

### Behavior Notes
- Mixed arithmetic with Ruby numbers works via coercion
- Immutable objects (create new instances, don't modify)
- Thread-safe (no shared mutable state)
- No locale dependencies (pure byte operations)

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

### Storage Efficiency
- **Small integers (1-99)**: 2 bytes (vs 8 for Float)
- **Common range (-999 to 999)**: 2-3 bytes
- **Typical numbers (-10^9 to 10^9)**: 4-6 bytes
- **Maximum 18 digits**: Variable length encoding

### Benchmark Results

Database sorting benchmark (1000 numbers):
- **EncodeM (direct byte sort)**: 8,459 ops/sec
- **Float (decode→sort→encode)**: 3,003 ops/sec (2.8x slower)
- **BigDecimal (parse→sort→string)**: 939 ops/sec (9x slower)

Range query benchmark (find values between -100 and 100):
- **EncodeM (byte comparison)**: 10,355 ops/sec
- **Float (decode & filter)**: 5,526 ops/sec (1.9x slower)

Run benchmarks yourself: `ruby -I lib test/benchmark_database.rb`

## Database & KV Store Usage

### Direct Byte Comparison for Range Queries
```ruby
# Store encoded numbers as keys in LMDB/RocksDB
db[M(100).to_encoded] = "user:100"
db[M(200).to_encoded] = "user:200"
db[M(300).to_encoded] = "user:300"

# Range query without decoding - pure byte comparison!
lower = M(150).to_encoded
upper = M(250).to_encoded
db.range(lower, upper)  # Returns user:200
```

### Composite Keys with Sort Order Preserved
```ruby
# Timestamp + ID composite key
def make_key(timestamp, id)
  M(timestamp).to_encoded + M(id).to_encoded
end

# These sort correctly by timestamp, then by ID
key1 = make_key(1699564800, 42)   # Nov 9, 2023 + ID 42
key2 = make_key(1699564800, 100)  # Nov 9, 2023 + ID 100
key3 = make_key(1699651200, 1)    # Nov 10, 2023 + ID 1

# Byte comparison gives correct chronological order
[key3, key1, key2].sort == [key1, key2, key3]  # => true
```

## Production Notes

### Thread Safety
- **Immutable objects**: All EncodeM instances are immutable
- **No shared state**: Safe for concurrent use across threads
- **Pure functions**: Encoding/decoding have no side effects

### Determinism & Portability
- **Deterministic encoding**: Same input → same bytes, always
- **Architecture independent**: No endianness issues
- **No locale dependencies**: Pure byte operations
- **Ruby version stable**: Tested on Ruby 2.5+ through 3.4

### Quality Assurance
- **Test coverage**: Comprehensive test suite with edge cases
- **Monotonicity verified**: Ordering guaranteed by property tests
- **Round-trip validation**: All values encode/decode perfectly
- **40-year production history**: Algorithm battle-tested in healthcare

### Performance Considerations
- **Zero allocations** for comparison operations
- **Lazy decoding**: Compare/sort without materializing numbers
- **Cache-friendly**: Sequential byte comparison is CPU-optimal
- **GC-friendly**: Small objects, minimal memory pressure

## Use Cases

- **Financial Systems**: More precision than Float, faster than BigDecimal
- **Database Indexing**: Sort encoded bytes directly
- **Time-Series Data**: Efficient storage with natural ordering
- **Healthcare Systems**: Proven in Epic, VistA, and other M-based systems
- **High-Volume Processing**: Efficient encoding for billions of records
- **Cross-System Integration**: Compatible with M language databases

## References & Attribution

### Algorithm Heritage
This gem implements the numeric encoding algorithm from YottaDB and GT.M, which has been proven in production systems for nearly 40 years.

**Algorithm Credit**:
- Original design: Greystone Technology Corporation (1980s)
- Current implementations: [YottaDB](https://gitlab.com/YottaDB/DB/YDB) (AGPLv3) and GT.M
- Production proven in Epic, VistA, and Profile banking systems

**Ruby Implementation**:
- Author: Steve Shreeve (steve.shreeve@gmail.com)
- Implementation assistance: Claude Opus 4.1 (Anthropic)
- **Clean-room reimplementation**: This is an independent implementation of the algorithm concept, not a code translation

### Technical References
- [YottaDB Collation Documentation](https://docs.yottadb.com/ProgrammersGuide/langfeat.html) - M language collation sequences
- [YottaDB Programmer's Guide](https://docs.yottadb.com/ProgrammersGuide/) - General M language reference
- [MUMPS Wikipedia](https://en.wikipedia.org/wiki/MUMPS) - Overview of M language history

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
