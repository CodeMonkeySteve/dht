class Host
  RefreshPeriod = 1.day
  RetryPeriod = 1.hour

  attr_reader :url
  attr_reader :active_at, :error_at
  attr_accessor :distance

  def initialize( url, distance = nil )
    @url = canonicalize url
    @distance = distance
    @active_at = nil
  end

  def ==( that )
    @url == that.url
  end

  def <=>( that )
    (@distance <=> that.distance) || (@active_at <=> that.active_at) || (@url <=> that.url)
  end

  def to_hash( hash = {} )
    hash.update( :url => @url.to_s )
    hash.update( :active_at => @active_at )  if @active_at
    hash
  end

#   def to_s
#     @url.to_s
#   end

  def refresh( from_node )
    # FIX ME!
    self.touch
  end

  def next_refresh_at
    if @error_at
      @error_at + self.class::RetryPeriod
    elsif @active_at
      @active_at + self.class::RefreshPeriod
    else
      Time.now
    end
  end

  def touch( at = Time.now )
    @active_at = at
    @error_at = nil
    self
  end

protected
  def canonicalize( url )
    url = (Addressable::URI === url) ? url : Addressable::URI.parse(url)
    url.port = nil  if url.port && (url.port == 80)
    url.path = '/'  if url.path.blank?
    url
  end
end
