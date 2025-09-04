# Changelog

All notable changes to the EncodeM project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-01-03

### 🎉 Major Features
- **Complete M language subscript support!** Now includes strings and composite keys
- String encoding with proper `0xFF` prefix and escape sequences
- Composite keys for hierarchical data structures (e.g., `M("users", 42, "email")`)
- Full compatibility with YottaDB/GT.M subscript encoding

### Added
- `EncodeM::String` class for string subscripts
- `EncodeM::Composite` class for multi-component keys
- Support for variadic arguments in `M()` function
- Automatic type detection (numeric strings parse as numbers)
- Comprehensive test suite for string and composite features
- Support for nil values (converted to empty strings)

### Changed
- Float values are now truncated to integers (M language only supports integer encoding)
- `M()` function can now accept multiple arguments for composite keys
- Decoder enhanced to handle strings and composite keys
- Division operations now perform integer division

### Examples
```ruby
# Strings
M("Hello")                   # String encoding
M("")                        # Empty string

# Composite keys
M("users", 42, "email")      # Database-style keys
M(2025, 1, 15)               # Date as composite
M("cache", namespace, key)    # Cache keys

# Mixed types
M("user", 123, "posts", -1)  # All types work together
```

## [2.0.0] - 2025-09-03

### Changed
- **BREAKING**: Fixed encoding to match actual M language specification
- Zero now encodes to 0x80 (was 0x40)
- Negative numbers use 0x3B-0x43 range (based on digit count)
- Positive numbers use 0xBC-0xC4 range (based on digit count)
- This is the correct YottaDB/GT.M encoding format

### Fixed
- Encoding now properly matches M language collation specification
- Documentation updated with accurate byte-level format specification

## [1.0.0] - 2025-09-03

### Added
- Initial release of EncodeM gem
- Core numeric encoding/decoding based on YottaDB/GT.M algorithm
- M() global convenience method for M language style
- Full arithmetic operations (+, -, *, /, **)
- Comparison operations maintaining sort order in encoded form
- Comprehensive test suite
- Documentation and examples

### Features
- Sortable byte encoding (key database feature)
- Optimized for common integer ranges
- 18-digit precision support
- Clean-room Ruby implementation of 40-year production algorithm

### Attribution
- Algorithm from YottaDB/GT.M (40 years in production)
- Ruby implementation by Steve Shreeve
- Implementation assistance from Claude Opus 4.1 (Anthropic)
