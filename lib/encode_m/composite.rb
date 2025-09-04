# Composite key encoding for M language subscripts
module EncodeM
  class Composite
    include Comparable
    
    attr_reader :components, :encoded
    
    def initialize(*components)
      raise ArgumentError, "Composite key requires at least one component" if components.empty?
      
      @components = components.map { |c| normalize_component(c) }
      @encoded = encode_composite(@components)
    end
    
    def to_a
      @components.map do |component|
        case component
        when EncodeM::Numeric
          component.value
        when EncodeM::String
          component.value
        else
          component
        end
      end
    end
    
    def to_encoded
      @encoded
    end
    
    def inspect
      "EncodeM::Composite(#{to_a.map(&:inspect).join(', ')})"
    end
    
    def [](index)
      @components[index]
    end
    
    def length
      @components.length
    end
    
    alias size length
    
    # Comparison operations
    def <=>(other)
      case other
      when EncodeM::Composite
        @encoded <=> other.encoded
      when EncodeM::Numeric, EncodeM::String
        # Single values sort before composites with same first element
        # This maintains hierarchical ordering
        first_comparison = @components.first <=> other
        first_comparison == 0 ? 1 : first_comparison
      else
        nil
      end
    end
    
    def ==(other)
      case other
      when EncodeM::Composite
        @components == other.components
      when Array
        to_a == other
      else
        false
      end
    end
    
    alias eql? ==
    
    def hash
      @components.hash
    end
    
    private
    
    def normalize_component(value)
      case value
      when EncodeM::Numeric, EncodeM::String
        value
      when EncodeM::Composite
        raise ArgumentError, "Cannot nest composite keys"
      when ::Numeric  # Use :: to ensure we get Ruby's Numeric
        EncodeM::Numeric.new(value)
      when ::String
        EncodeM::String.new(value)
      when NilClass
        EncodeM::String.new("")  # nil becomes empty string in M
      else
        raise ArgumentError, "Unsupported type in composite key: #{value.class}"
      end
    end
    
    def encode_composite(components)
      encoded_parts = components.map(&:to_encoded)
      
      # Join with KEY_DELIMITER (0x00)
      # Each component is separated by 0x00 to maintain hierarchical sorting
      encoded_parts.join([Encoder::KEY_DELIMITER].pack('C'))
    end
  end
end
