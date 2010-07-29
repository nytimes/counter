# Basic counting.
#
# === To count:
#
# Easiest way to count is to increment while iterating over data:
#
#  c = Counter.new
#  c.increment('some-key')
#  c.saw('some-key')  # alias
#
# But you can also set counts directly:
#  c = Counter.new
#  c.set('another-key', 42)
#
# === To get counts back:
#
# You can use Hash-style syntax:
#  puts c['some-key]
#  => 2
#
# or ask for the top-n keys as an array of [key, count]
#
#  puts c.top(2)
#  => [['key-1',50],['key-2',38]]
#
# or just ask for data for all keys:
#  puts c.counts
#  => [['key-1',50],['key-2',38],['key-3',22]]
#
# === Some notes
# * 0 is returned, even if key has never been seen
# * if ties exist in a top-n ranking, they are broken by sort on key
class Counter
    
  def initialize
    @data = Hash.new(0)
  end
  
  # key++
  def increment key
    @data[key] += 1
    true
  end
  alias_method :saw, :increment
  
  # sets the key to a specified value
  def set key, count
    raise ArgumentError, "count must be numeric" if !count.is_a?(Numeric)
    @data[key] = count
  end
  
  # Retrieve the count for a particular key
  def [] key
    @data[key]
  end
  
  # Returns all elements as [key, count] array
  def counts
    sorted_data
  end
  
  # Returns top <tt>n</tt> elements as [key,count] array
  def top n
    sorted_data[0,n]
  end
    
  def to_a
    @data.to_a
  end
  
  private
  def sorted_data
    @data.to_a.sort { |a,b| a[1] != b[1] ? a[1] <=> b[1] : b[0] <=> a[0] }.reverse
  end
  
end
