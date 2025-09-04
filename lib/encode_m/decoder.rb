# Decoder for M language numeric encoding
module EncodeM
  class Decoder
    POS_DECODE = Encoder::POS_CODE.each_with_index.map { |v, i| [v, i] }.to_h.freeze
    NEG_DECODE = Encoder::NEG_CODE.each_with_index.map { |v, i| [v, i] }.to_h.freeze

    def self.decode(encoded_bytes)
      bytes = encoded_bytes.unpack('C*')
      return 0 if bytes[0] == Encoder::SUBSCRIPT_ZERO

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
  end
end