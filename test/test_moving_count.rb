require 'test_helper'

class MovingCountTest < Test::Unit::TestCase
  
  def setup
    Timecop.return
    [PageView, Click].each { |m| m.delete_all }
  end
  
  context "record" do
    
    should "save counts to the database" do
      PageView.record_counts do |c|
        c.saw('http://www.nytimes.com')
        c.saw('http://www.nytimes.com')
        c.saw('http://www.nytimes.com/article.html')        
      end
      
      assert_equal 2, PageView.find_by_category('http://www.nytimes.com').count
      assert_equal 1, PageView.find_by_category('http://www.nytimes.com/article.html').count
    end
    
    should "not save if no data was recorded" do
      assert_nothing_raised { PageView.record_counts { |c| } }
      assert_equal 0, PageView.count
    end
    
    context "sample interval" do
      should "raise a RuntimeError to enforce sample interval" do
        setup_existing_counts(59)
        assert_raises(RuntimeError) { PageView.record_counts { |c| c.saw('http://www.nytimes.com') } }
      end
    
      should "default sample interval to 60 seconds" do
        setup_existing_counts(60)
        assert_nothing_raised { PageView.record_counts { |c| c.saw('http://www.nytimes.com') } }
      end
    
      should "respect custom sample interval" do
        setup_existing_counts(5, Click)
        assert_nothing_raised { Click.record_counts { |c| c.saw('http://www.nytimes.com') } }
      end

      should "allow samples to be backfilled" do
        setup_existing_counts(60)
        assert_nothing_raised { PageView.record_counts(Time.now - 3600) { |c| c.saw('http://www.nytimes.com') } }
      end
    end
    
    context "sample_time" do
      should "record provided timestamp as sample time" do
        stamp = Time.now - 300
        PageView.record_counts(stamp) do |c|
          c.saw('http://www.nytimes.com')
          c.saw('http://www.nytimes.com/article.html')        
        end
      
        assert_equal 2, PageView.count(:conditions => {:sample_time => stamp})
      end
    
      should "use Time.now as the timestamp if none specified" do
        Timecop.freeze
      
        PageView.record_counts do |c|
          c.saw('http://www.nytimes.com')
          c.saw('http://www.nytimes.com/article.html')        
        end
      
        assert_equal 2, PageView.count(:conditions => {:sample_time => Time.now})
      end
      
      should "use allow timestamp to be specified as a UNIX stamp" do
        Timecop.freeze
      
        PageView.record_counts(Time.now.to_i) do |c|
          c.saw('http://www.nytimes.com')
          c.saw('http://www.nytimes.com/article.html')        
        end
      
        assert_equal 2, PageView.count(:conditions => {:sample_time => Time.now})
      end
    end
    
    context "purge" do
      should "purge data older than history_to_keep" do
        setup_existing_counts(2.hours)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com') }
        assert_equal 1, PageView.count
      end
      
      should "set default history_to_keep at 1 hour" do
        setup_existing_counts(59.minutes)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com') }
        assert_equal 2, PageView.count
      end
      
      should "respect custom history_to_keep" do
        setup_existing_counts(5.minutes, Click)
        Click.record_counts { |c| c.saw('http://www.nytimes.com') }
        assert_equal 1, Click.count
      end
    end


    context "totals" do
      should "returns totals across all samples in the history" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com'); c.saw('http://www.nytimes.com/article.html') }
        
        assert_equal [['http://www.nytimes.com',3],['http://www.nytimes.com/article.html',1]], PageView.totals
      end
      
      should "match against category_like if provided" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com'); c.saw('http://www.nytimes.com/article.html') }
        
        assert_equal [['http://www.nytimes.com/article.html',1]],
                     PageView.totals(:category_like => 'http://www.nytimes.com/article%')
      end
      
      should "filter to window if provided" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        
        assert_equal [['http://www.nytimes.com',1]], PageView.totals(:window => 5.minutes)
      end
      
      should "respect limit if provided" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com'); c.saw('http://www.nytimes.com/article.html') }
        
        assert_equal [['http://www.nytimes.com',3]], PageView.totals(:limit => 1)
      end
    end
    
    context "grand total" do
      
      should "return total sum across all samples" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        
        assert_equal 2, PageView.grand_total
      end
      
      should "match against category_like if providedd" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        PageView.record_counts { |c| c.saw('http://www.nytimes.com'); c.saw('http://www.nytimes.com/article.html') }
        
        assert_equal 1, PageView.grand_total(:category_like => 'http://www.nytimes.com/article%')
      end
      
      should "filter to window if provided" do
        setup_existing_counts(10.minutes)
        setup_existing_counts(5.minutes)
        
        assert_equal 1, PageView.grand_total(:window => 5.minutes)
      end
    end
    
  end
  
  def setup_existing_counts distance, model=PageView
    Timecop.freeze(Time.now - distance)
    model.record_counts { |c| c.saw('http://www.nytimes.com') }
    Timecop.freeze(Time.now + distance)
  end
  
end