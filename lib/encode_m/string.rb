# String encoding for M language subscripts
module EncodeM
  class String
    include Comparable

    attr_reader :value, :encoded

    def initialize(value)
      @value = value.to_s
      @encoded = encode_string(@value)
    end

    def to_s
      @value
    end

    def to_encoded
      @encoded
    end

    def inspect
      "EncodeM::String(#{@value.inspect})"
    end

    # String-specific predicates
    def empty?
      @value.empty?
    end

    def length
      @value.length
    end

    # Comparison operations
    def <=>(other)
      case other
      when EncodeM::String
        @encoded <=> other.encoded
      when EncodeM::Numeric
        1  # Strings always sort after numbers in M language
      when EncodeM::Composite
        # Let Composite handle the comparison
        -(other <=> self)
      else
        nil
      end
    end

    def ==(other)
      case other
      when EncodeM::String
        @value == other.value
      when ::String
        @value == other
      else
        false
      end
    end

    alias eql? ==

    def hash
      @value.hash
    end

    private

    def encode_string(str)
      result = [Encoder::STR_SUB_PREFIX]  # 0xFF prefix for strings

      str.bytes.each do |byte|
        if byte == Encoder::KEY_DELIMITER || byte == Encoder::STR_SUB_ESCAPE
          # Escape special bytes: 0x00 and 0x01
          # Use 0x01 followed by (byte XOR 0xFF)
          result << Encoder::STR_SUB_ESCAPE
          result << (byte ^ 0xFF)
        else
          result << byte
        end
      end

      result.pack('C*')
    end
  end
end
