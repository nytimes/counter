ActiveRecord::Schema.define(:version => 1) do

  create_table :page_views, :force => true do |t|
    t.string   :category,      :null => false
    t.integer  :count,         :null => false, :default => 0
    t.datetime :sample_time,   :null => false
  end
  
  add_index :page_views, :category

  create_table :clicks, :force => true do |t|
    t.string   :category,      :null => false
    t.integer  :count,         :null => false, :default => 0
    t.datetime :sample_time,   :null => false
  end


end