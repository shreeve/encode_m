# EncodeM - Complete M language subscript encoding for Ruby
# Based on YottaDB/GT.M's 40-year production-tested algorithm

require 'encode_m/version'
require 'encode_m/encoder'
require 'encode_m/decoder'
require 'encode_m/numeric'
require 'encode_m/string'
require 'encode_m/composite'

module EncodeM
  class Error < StandardError; end

  # Factory method supporting all M types
  def self.new(*values)
    if values.length == 1
      create_single(values[0])
    else
      Composite.new(*values)
    end
  end

  # Decode - reverse the M encoding
  def self.decode(encoded)
    Decoder.decode(encoded)
  end
  
  # Decode composite keys
  def self.decode_composite(encoded)
    Decoder.decode_composite(encoded)
  end

  # M language style constructor
  def self.M(*values)
    if values.length == 1
      create_single(values[0])
    else
      Composite.new(*values)
    end
  end
  
  private
  
  def self.create_single(value)
    case value
    when EncodeM::Numeric, EncodeM::String, EncodeM::Composite
      value  # Already encoded
    when ::Numeric  # Use :: to ensure we get Ruby's Numeric, not EncodeM::Numeric
      Numeric.new(value)
    when ::String
      # Try to parse as a number first
      begin
        Numeric.new(value)
      rescue ArgumentError
        # Not a number, treat as string
        String.new(value)
      end
    when NilClass
      String.new("")  # nil becomes empty string in M
    else
      raise ArgumentError, "Unsupported type: #{value.class}"
    end
  end
end

# Global convenience method (like M language global functions)
def M(*values)
  EncodeM.M(*values)
end
