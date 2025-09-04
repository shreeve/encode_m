# Encoding algorithm adapted from YottaDB/GT.M's mval2subsc.c
# This production-tested algorithm has powered M language systems since the 1980s
module EncodeM
  class Encoder
    # Constants from the M language subscript encoding
    SUBSCRIPT_BIAS = 0x40
    SUBSCRIPT_ZERO = 0x40
    STR_SUB_PREFIX = 0x0A
    STR_SUB_ESCAPE = 0x01
    NEG_MNTSSA_END = 0xFF
    KEY_DELIMITER = 0x00
    SUBSCRIPT_STDCOL_NULL = 0xFF

    # Encoding tables from YottaDB's production code
    POS_CODE = [
      0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a,
      0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a,
      0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a,
      0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a,
      0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a,
      0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a,
      0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a,
      0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a,
      0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a,
      0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a
    ].freeze

    NEG_CODE = [
      0xfe, 0xfd, 0xfc, 0xfb, 0xfa, 0xf9, 0xf8, 0xf7, 0xf6, 0xf5,
      0xee, 0xed, 0xec, 0xeb, 0xea, 0xe9, 0xe8, 0xe7, 0xe6, 0xe5,
      0xde, 0xdd, 0xdc, 0xdb, 0xda, 0xd9, 0xd8, 0xd7, 0xd6, 0xd5,
      0xce, 0xcd, 0xcc, 0xcb, 0xca, 0xc9, 0xc8, 0xc7, 0xc6, 0xc5,
      0xbe, 0xbd, 0xbc, 0xbb, 0xba, 0xb9, 0xb8, 0xb7, 0xb6, 0xb5,
      0xae, 0xad, 0xac, 0xab, 0xaa, 0xa9, 0xa8, 0xa7, 0xa6, 0xa5,
      0x9e, 0x9d, 0x9c, 0x9b, 0x9a, 0x99, 0x98, 0x97, 0x96, 0x95,
      0x8e, 0x8d, 0x8c, 0x8b, 0x8a, 0x89, 0x88, 0x87, 0x86, 0x85,
      0x7e, 0x7d, 0x7c, 0x7b, 0x7a, 0x79, 0x78, 0x77, 0x76, 0x75,
      0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x69, 0x68, 0x67, 0x66, 0x65
    ].freeze

    def self.encode_integer(value)
      return [SUBSCRIPT_ZERO].pack('C') if value == 0

      is_negative = value < 0
      mt = is_negative ? -value : value
      cvt_table = is_negative ? NEG_CODE : POS_CODE
      result = []

      # Encode based on the number of digit pairs needed
      # This maintains sort order and proper encoding/decoding

      # Count digit pairs needed (each pair holds 00-99)
      temp = mt
      pairs = []
      while temp > 0
        pairs.unshift(temp % 100)
        temp /= 100
      end

      # If no pairs (shouldn't happen for non-zero), add the number itself
      pairs = [mt] if pairs.empty?

      # The exponent represents the number of pairs
      # For sorting: more pairs = larger magnitude
      # We use SUBSCRIPT_BIAS + num_pairs to avoid conflict with SUBSCRIPT_ZERO
      num_pairs = pairs.length
      exp_byte = SUBSCRIPT_BIAS + num_pairs  # Not -1, to stay above SUBSCRIPT_ZERO

      # Encode the exponent byte
      # For negatives, we need values < 0x40 that decrease as magnitude increases
      # This ensures negatives sort before zero and in correct order
      if is_negative
        # Mirror the positive exponent below 0x40
        # Larger magnitudes get smaller bytes for correct sorting
        neg_exp_byte = 0x40 - (exp_byte - 0x40) - 1
        result << neg_exp_byte
      else
        result << exp_byte
      end

      # Encode the mantissa pairs
      pairs.each { |pair| result << cvt_table[pair] }

      result << NEG_MNTSSA_END if is_negative && mt != 0
      result.pack('C*')
    end

    def self.encode_decimal(value, result = [])
      str_val = value.to_s
      is_negative = str_val.start_with?('-')
      str_val = str_val[1..-1] if is_negative

      parts = str_val.split('.')
      integer_part = parts[0].to_i

      exp = integer_part == 0 ? 0 : Math.log10(integer_part).floor + 1
      mantissa = (str_val.delete('.').ljust(18, '0')[0...18]).to_i

      cvt_table = is_negative ? NEG_CODE : POS_CODE
      result << (is_negative ? ~(exp + SUBSCRIPT_BIAS) : (exp + SUBSCRIPT_BIAS))

      temp = mantissa
      digits = []
      while temp > 0 && digits.length < 9
        digits.unshift(temp % 100)
        temp /= 100
      end

      digits.each { |pair| result << cvt_table[pair] }
      result
    end

    private

    def self.encode_with_exp(mt, exp_val, is_negative, cvt_table, result)
      result << (is_negative ? ~exp_val : exp_val)

      pairs = []
      temp = mt
      while temp > 0
        pairs.unshift(temp % 100)
        temp /= 100
      end

      pairs.each { |pair| result << cvt_table[pair] }
    end
  end
end
