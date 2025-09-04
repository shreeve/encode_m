# EncodeM::Numeric - Bringing M language efficiency to Ruby
module EncodeM
  class Numeric
    include Comparable

    attr_reader :value, :encoded

    # M language typically uses 18-digit precision
    MAX_PRECISION = 18

    def initialize(value)
      @value = parse_value(value)
      @encoded = Encoder.encode_integer(@value.is_a?(Integer) ? @value : @value.to_i)
    end

    def to_i
      @value.to_i
    end

    def to_f
      @value.to_f
    end

    def to_s
      @value.to_s
    end

    def to_encoded
      @encoded
    end

    # Arithmetic operations
    def +(other)
      self.class.new(@value + coerce_value(other))
    end

    def -(other)
      self.class.new(@value - coerce_value(other))
    end

    def *(other)
      self.class.new(@value * coerce_value(other))
    end

    def /(other)
      divisor = coerce_value(other)
      raise ZeroDivisionError if divisor == 0

      if @value.is_a?(Integer) && divisor.is_a?(Integer) && @value % divisor == 0
        self.class.new(@value / divisor)
      else
        self.class.new(@value.to_f / divisor.to_f)
      end
    end

    def **(other)
      self.class.new(@value ** coerce_value(other))
    end

    # M language feature: encoded comparison
    def <=>(other)
      case other
      when EncodeM::Numeric
        @encoded <=> other.encoded
      when EncodeM::String
        -1  # Numbers always sort before strings in M language
      when EncodeM::Composite
        # Let Composite handle the comparison
        -(other <=> self)
      when Numeric
        @encoded <=> self.class.new(other).encoded
      else
        nil
      end
    end

    def ==(other)
      case other
      when EncodeM::Numeric
        @value == other.value
      when Numeric
        @value == other
      else
        false
      end
    end

    def abs
      self.class.new(@value.abs)
    end

    def negative?
      @value < 0
    end

    def positive?
      @value > 0
    end

    def zero?
      @value == 0
    end

    def round(n = 0)
      if n == 0
        self.class.new(@value.round)
      else
        self.class.new(@value.to_f.round(n))
      end
    end

    private

    def parse_value(val)
      case val
      when Integer
        val
      when Float
        raise ArgumentError, "Cannot represent Infinity" if val.infinite?
        raise ArgumentError, "Cannot represent NaN" if val.nan?
        val.to_i  # M language only supports integer encoding
      when ::String
        if val.include?('.')
          Float(val).to_i  # M language only supports integer encoding
        else
          Integer(val)
        end
      when self.class
        val.value
      else
        raise ArgumentError, "Cannot convert #{val.class} to EncodeM::Numeric"
      end
    end

    def coerce_value(other)
      case other
      when self.class
        other.value
      when ::Numeric
        other
      else
        raise TypeError, "Cannot coerce #{other.class} with EncodeM::Numeric"
      end
    end
  end
end
