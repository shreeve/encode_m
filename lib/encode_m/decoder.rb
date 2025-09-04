# Decoder for M language encoding (numeric and string)
module EncodeM
  class Decoder
    POS_DECODE = Encoder::POS_CODE.each_with_index.map { |v, i| [v, i] }.to_h.freeze
    NEG_DECODE = Encoder::NEG_CODE.each_with_index.map { |v, i| [v, i] }.to_h.freeze

    def self.decode(encoded_bytes)
      bytes = encoded_bytes.unpack('C*')
      
      # Check for string prefix
      if bytes[0] == Encoder::STR_SUB_PREFIX
        decode_string(bytes)
      elsif bytes[0] == Encoder::SUBSCRIPT_ZERO
        0
      else
        decode_numeric(bytes)
      end
    end
    
    def self.decode_composite(encoded_bytes)
      components = []
      bytes = encoded_bytes.unpack('C*')
      current = []
      
      bytes.each do |byte|
        if byte == Encoder::KEY_DELIMITER
          # End of component
          unless current.empty?
            components << decode(current.pack('C*'))
            current = []
          end
        else
          current << byte
        end
      end
      
      # Don't forget the last component
      components << decode(current.pack('C*')) unless current.empty?
      
      components
    end
    
    private
    
    def self.decode_numeric(bytes)
      first_byte = bytes[0]
      
      # Determine if negative based on first byte
      # Negative: 0x3B-0x43, Positive: 0xBC-0xC4
      is_negative = first_byte < Encoder::SUBSCRIPT_ZERO
      
      if is_negative
        decode_table = NEG_DECODE
      else
        decode_table = POS_DECODE
      end

      mantissa = 0

      # Decode mantissa from remaining bytes
      bytes[1..-1].each do |byte|
        break if byte == Encoder::NEG_MNTSSA_END || byte == Encoder::KEY_DELIMITER

        digit_pair = decode_table[byte]
        next unless digit_pair

        mantissa = mantissa * 100 + digit_pair
      end

      # The mantissa is the actual number value
      result = mantissa

      is_negative ? -result : result
    end
    
    def self.decode_string(bytes)
      result = []
      i = 1  # Skip the 0xFF prefix
      
      while i < bytes.length
        if bytes[i] == Encoder::STR_SUB_ESCAPE && i + 1 < bytes.length
          # Unescape: next byte is XORed with 0xFF
          result << (bytes[i + 1] ^ 0xFF)
          i += 2
        else
          result << bytes[i]
          i += 1
        end
      end
      
      # Force UTF-8 encoding for proper string handling
      result.pack('C*').force_encoding('UTF-8')
    end
  end
end