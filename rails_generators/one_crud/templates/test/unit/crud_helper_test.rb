require 'test_helper'

class CrudHelperTest < ActionView::TestCase
  
  include StandardHelper
  
  def model_class
    
  end
  
  test "standard crud table" do
    @entries = []
    assert_dom_equal "<div class='list'>#{NO_LIST_ENTRIES_MESSAGE}</div>", crud_table
  end
    
  test "custom crud table" do
    
  end
  
  test "default attributes do not include id" do 
    
  end
  
end
