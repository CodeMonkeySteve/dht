require 'spec_helper'
require 'dht/cache'
require 'dht/host'

include DHT

describe Cache do
  before do
    Timecop.freeze
    @cache = Cache.new Key.for_content('cache')
    @key, @host = Key.for_content('foo'), Host.new('http://nowhere.localdomain')
    @cache.add(@host, @key).should == @host
    @cache.should be_include(@host)
  end

  it '#inspect' do
    @cache.inspect.should == "  #{@key.inspect}: #{@host.inspect}\n"
  end

  it '#to_hash' do
    @cache.to_hash.should == [@host.to_hash]
  end

  it '#add (old)' do
    host = @cache.add( Host.new(@host.url), @key )
    host.should == @host
    @host.active_at.should be_nil
    @cache.should == [@host]
  end

  it '#add (new)' do
    url = 'http://nowhere2.localdomain'
    host = @cache.add( Host.new(url), @key )
    host.should_not be_nil
    host.active_at.should be_nil
    @cache.to_a.should == [@host, host]
  end

  it '#touch (old)' do
    host = @cache.touch @host, @key
    host.should == @host
    @host.active_at.should == Time.now
  end
end
