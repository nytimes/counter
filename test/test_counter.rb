require 'test_helper'

class CounterTest < Test::Unit::TestCase

  def setup
    @c = Counter.new
  end

  should "increment count every time increment is called for a key" do
    @c.increment('some-key')
    @c.increment('some-key')
    assert_equal 2, @c['some-key']
  end
  
  should "return 0 even if key has never been incremented" do
    assert_equal 0, @c['some-key']
  end
  
  should "return count directly if it was set" do
    @c.set('some-key', 65)
    assert_equal 65, @c['some-key']
  end
  
  should "raise an ArgumentError if set called with a non-numeric" do
    assert_raises(ArgumentError) { @c.set('some-key', Time.now) }
  end
  
  should "return counts as a [[key,cnt]] array" do
    @c.set('some-key',    32)
    @c.set('another-key', 45)
    
    assert_equal [['another-key',45],['some-key',32]], @c.counts
  end
  
  should "return top(n) as a [[key,cnt]] array of top n objects based on count" do
    @c.set('some-key',    32)
    @c.set('another-key', 45)
    @c.set('some-key-3',  90)
    
    assert_equal [['some-key-3',90],['another-key',45]], @c.top(2)
  end
  
  should "break top(n) ties on key name" do
    @c.set('some-key-1', 34)
    @c.set('some-key-2', 34)
    
    assert_equal [['some-key-1', 34]], @c.top(1)
  end
  
end
