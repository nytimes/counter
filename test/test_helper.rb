require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'timecop'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'counter'

class Test::Unit::TestCase
end

require 'counter/moving_count'

require 'active_record'
ActiveRecord::Base.establish_connection :adapter => 'mysql', :database => 'counter_test'
silence_stream(STDOUT) do
  load(File.dirname(__FILE__) + "/schema.rb")
end

class PageView < MovingCount
end

class Click < MovingCount
  set_sample_interval 5.seconds
  set_history_to_keep 2.minutes
end