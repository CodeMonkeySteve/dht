require 'spec_helper'
require 'dht/value_cache'

include DHT

describe ValueCache do
  before do
    Timecop.freeze
    @cache = ValueCache.new Key.for_content('cache')
    @key, @val = Key.for_content('foo'), 'bar'
    @entry = @cache.touch @key, @val
  end

  it '#inspect' do
    @cache.inspect.should ==
      "  #{@key.inspect} (#{'%040x' % @key.distance_to(@cache.key)}): #{@val}\n"
  end

  it '#to_a' do
    @cache.to_a.should == [@entry.to_hash]
  end

  it '#touch' do
    val = 'splat'
    entry = @cache.touch( @key, val )
    entry.active_at.should == Time.now
    @cache.entries.should include(entry)
  end

  it '#add' do
    val = 'splat'
    entry = @cache.add( @key, val )
    entry.should_not be_nil
    entry.active_at.should be_nil
    @cache.entries.should == [@entry, entry]
  end
end
