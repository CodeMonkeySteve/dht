require 'digest/sha1'
require 'dht/core_ext'

module DHT

class Key
  Digest = ::Digest::SHA1
  Size = Digest.new.digest_length

  def self.for_content( content )
    Key.new Digest.digest( content )
  end

  def initialize( key )
    @key =
      if Integer === key
        @key_i = key
        k = @key_i.to_s(16)
        [('0' * ((Size * 2) - k.size)) + k].pack('H*')
      else
        key = key.to_s
        case key.size
          when Size      then  key
          when Size * 2  then  [key].pack('H*')
          else           raise "Invalid key: #{key}"
        end
      end
  end

  def ==( that )
    self.eql? that
  end
  def to_s
    @key
  end
  def hash
    @key.hash
  end
  def eql?( that )
    @key == that.to_s
  end

  def inspect
    to_s.unpack('H*').first
  end
  def to_i
    @key_i ||= eval( '0x'+to_s.unpack('H*').first )
  end

  def distance_to( that )
    self.to_i ^ that.to_i
  end
end

end
