# EncodeM - Bringing M language numeric encoding to Ruby
# Based on YottaDB/GT.M's 40-year production-tested algorithm

require 'encode_m/version'
require 'encode_m/encoder'
require 'encode_m/decoder'
require 'encode_m/numeric'

module EncodeM
  class Error < StandardError; end

  # Factory method honoring M language convention
  def self.new(value)
    Numeric.new(value)
  end

  # Decode - reverse the M encoding
  def self.decode(encoded)
    Decoder.decode(encoded)
  end

  # Alias for M language users
  def self.M(value)
    Numeric.new(value)
  end
end

# Global convenience method (like M language global functions)
def M(value)
  EncodeM::Numeric.new(value)
end
