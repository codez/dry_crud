require 'test_helper'

class StandardHelperTest < ActionView::TestCase

	include StandardHelper
	
  def format_size(obj)
    "#{f(obj.size)} chars"
  end
  
	test "labeled text as block" do
		result = labeled("label") { "value" }
		
		assert_dom_equal "<div class='labeled'><span class='caption'>label</span><span class='value'>value</span></div>", result
  end

  test "labeled text as content" do
    result = labeled("label", "value")
    
    assert_dom_equal "<div class='labeled'><span class='caption'>label</span><span class='value'  >value</span></div>", result
  end
  
	test "alternate row" do
		result_1 = tr_alt { "(test row content)" }
		result_2 = tr_alt { "(test row content)" }

		assert_dom_equal "<tr class='even'>(test row content)</tr>", result_1
		assert_dom_equal "<tr class='odd'>(test row content)</tr>", result_2
	end
	
	test "format Fixnums" do
		assert_equal "0", f(0)
		assert_equal "10", f(10)
	end
	
	test "format Floats" do
		assert_equal "1.00", f(1.0)
		assert_equal "1.20", f(1.2)
		assert_equal "3.14", f(3.14159)
	end
	
	test "format Booleans" do
		assert_equal "yes", f(true)
		assert_equal "no", f(false)
	end
	
	test "format nil" do
		assert_equal "", f(nil)
	end
	
	test "format Strings" do
		assert_equal "blah blah", f("blah blah")
 		assert_equal "&lt;injection&gt;", f("<injection>")
  end

  test "format attr with fallthrough to f" do
    assert_equal "12.23", format_attr("12.23424", :to_f)
  end
  
  test "format attr with custom format_size method" do
    assert_equal "4 chars", format_attr("abcd", :size)
  end
	
	test "empty table should render message" do
		assert_dom_equal "<div class='list'>#{NO_LIST_ENTRIES_MESSAGE}</div>", table([]) { }
	end	
	
  test "non empty table should render table" do
    assert_match(/^\<table.*\<\/table\>$/, table(['foo', 'bar']) {|t| t.attrs :size, :upcase })
  end
	

end