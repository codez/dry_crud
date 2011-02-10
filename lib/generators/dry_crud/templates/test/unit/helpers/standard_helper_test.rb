require 'test_helper'
require 'crud_test_model'

class StandardHelperTest < ActionView::TestCase

  include StandardHelper
  include CrudTestHelper
  
  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db
  
  def format_size(obj)
    "#{f(obj.size)} chars"
  end
  
  test "labeled text as block" do
    result = labeled("label") { "value" }
    
    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <div class='caption'>label</div> <div class='value'>value</div> </div>", result.squish
  end

  test "labeled text empty" do
    result = labeled("label", "")
    
    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <div class='caption'>label</div> <div class='value'>#{EMPTY_STRING}</div> </div>", result.squish
  end

  test "labeled text as content" do
    result = labeled("label", "value <unsafe>")
    
    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <div class='caption'>label</div> <div class='value'>value &lt;unsafe&gt;</div> </div>", result.squish
  end
  
  test "labeled attr" do
  	result = labeled_attr('foo', :size)
  	assert result.html_safe?
  	assert_dom_equal "<div class='labeled'> <div class='caption'>Size</div> <div class='value'>3 chars</div> </div>", result.squish
  end
  
  test "alternate row" do
    result_1 = tr_alt { "(test row content)" }
    result_2 = tr_alt { "(test row content)" }

    assert result_1.html_safe?
    assert result_2.html_safe?
    assert_dom_equal "<tr class='even'>(test row content)</tr>", result_1
    assert_dom_equal "<tr class='odd'>(test row content)</tr>", result_2
  end
  
  test "format Fixnums" do
    assert_equal "0", f(0)
    assert_equal "10", f(10)
    assert_equal "10,000,000", f(10000000)    
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
    assert EMPTY_STRING.html_safe?
    assert_equal EMPTY_STRING, f(nil)
  end
  
  test "format Strings" do
    assert_equal "blah blah", f("blah blah")
    assert_equal "<injection>", f("<injection>")
    assert !f("<injection>").html_safe?
  end

  test "format attr with fallthrough to f" do
    assert_equal "12.23", format_attr("12.23424", :to_f)
  end
  
  test "format attr with custom format_size method" do
    assert_equal "4 chars", format_attr("abcd", :size)
  end
  
  test "column types" do
    m = crud_test_models(:AAAAA)
    assert_equal :string, column_type(m, :name)
    assert_equal :integer, column_type(m, :children)
    assert_equal :integer, column_type(m, :companion_id)
    assert_equal nil, column_type(m, :companion)
    assert_equal :float, column_type(m, :rating)
    assert_equal :decimal, column_type(m, :income)
    assert_equal :date, column_type(m, :birthdate)
    assert_equal :boolean, column_type(m, :human)
    assert_equal :text, column_type(m, :remarks)
  end
  
  test "format integer column" do
    m = crud_test_models(:AAAAA)
    assert_equal '9', format_type(m, :children)
    
    m.children = 10000
    assert_equal '10,000', format_type(m, :children)
  end
  
  test "format float column" do
    m = crud_test_models(:AAAAA)
    assert_equal '1.10', format_type(m, :rating)
    
    m.rating = 3.145001   # you never know with these floats..
    assert_equal '3.15', format_type(m, :rating)
  end
  
  test "format decimal column" do
    m = crud_test_models(:AAAAA)
    assert_equal '10000000.10', format_type(m, :income)
  end
  
  test "format date column" do
    m = crud_test_models(:AAAAA)
    assert_equal '1910-01-01', format_type(m, :birthdate)
  end
    
  test "format datetime column" do
    m = crud_test_models(:AAAAA)
    assert_equal f(m.created_at.to_date) + " " + f(m.created_at.to_time), format_type(m, :created_at)
  end
  
  test "format text column" do
    m = crud_test_models(:AAAAA)
    assert_equal "<p>AAAAA BBBBB CCCCC\n<br />AAAAA BBBBB CCCCC\n</p>", format_type(m, :remarks)
    assert format_type(m, :remarks).html_safe?
  end
  
  test "empty table should render message" do
    result = table([]) { }
    assert result.html_safe?
    assert_dom_equal "<div class='list'>#{NO_LIST_ENTRIES_MESSAGE}</div>", result
  end  
  
  test "non empty table should render table" do
    result = table(['foo', 'bar']) {|t| t.attrs :size, :upcase }
    assert result.html_safe?
    assert_match(/^\<table.*\<\/table\>$/, result)
  end
  
  test "table with attrs" do
    expected = StandardTableBuilder.table(['foo', 'bar'], self) { |t| t.attrs :size, :upcase }
    actual = table(['foo', 'bar'], :size, :upcase)
    assert actual.html_safe?
    assert_equal expected, actual
  end
  
  test "captionize" do
    assert_equal "Camel Case", captionize(:camel_case)
    assert_equal "All Upper Case", captionize("all upper case")
    assert_equal "With Object", captionize("With object", Object.new)
    assert !captionize('bad <title>').html_safe?
  end
  
  test "standard form for existing entry" do
    e = crud_test_models('AAAAA')
    f = with_test_routing do 
      f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    end
  
    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f 
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="number" .*?value=\"9\"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
  test "standard form for new entry" do
    e = CrudTestModel.new
    f = with_test_routing do 
      f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    end
  
    assert_match /form .*?action="\/crud_test_models" .*?method="post"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_no_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value=/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="number"/, f
    assert_no_match /input .*?name="crud_test_model\[children\]" .*?type="text" .*?value=/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
  test "standard form with errors" do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?
    
    f = with_test_routing do 
      f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    end
  
    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
    assert_match /div id="error_explanation"/, f
    assert_match /div class="field_with_errors"\>.*?\<input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="number" .*?value=\"9\"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
end
