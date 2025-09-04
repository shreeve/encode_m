# Changelog

All notable changes to the EncodeM project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
