module DHT

class Host
  attr_reader :url

  def initialize( url )
    @url = url
    @active_at = nil
    yield self  if block_given?
  end

  def inspect
    self.url
  end

  def touch
    @active_at = Time.now
  end
end

end