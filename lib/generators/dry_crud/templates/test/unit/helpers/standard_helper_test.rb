require 'test_helper'
require 'crud_test_model'

class StandardHelperTest < ActionView::TestCase

  include StandardHelper
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  def format_size(obj)
    "#{f(obj.size)} items"
  end

  def format_string_size(obj)
    "#{f(obj.size)} chars"
  end

  test "labeled text as block" do
    result = labeled("label") { "value" }

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>value</div> </div>", result.squish
  end

  test "labeled text empty" do
    result = labeled("label", "")

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>#{EMPTY_STRING}</div> </div>", result.squish
  end

  test "labeled text as content" do
    result = labeled("label", "value <unsafe>")

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>value &lt;unsafe&gt;</div> </div>", result.squish
  end

  test "labeled attr" do
    result = labeled_attr('foo', :size)
    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>Size</label> <div class='value'>3 chars</div> </div>", result.squish
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

  test "format attr with custom format_string_size method" do
    assert_equal "4 chars", format_attr("abcd", :size)
  end

  test "format attr with custom format_size method" do
    assert_equal "2 items", format_attr([1,2], :size)
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
    assert_equal :time, column_type(m, :gets_up_at)
    assert_equal :datetime, column_type(m, :last_seen)
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
    assert_equal '10,000,000.10', format_type(m, :income)
  end

  test "format date column" do
    m = crud_test_models(:AAAAA)
    assert_equal '1910-01-01', format_type(m, :birthdate)
  end

  test "format time column" do
    m = crud_test_models(:AAAAA)
    assert_equal '01:01', format_type(m, :gets_up_at)
  end

  test "format datetime column" do
    m = crud_test_models(:AAAAA)
    assert_equal "2010-01-01 11:21", format_type(m, :last_seen)
  end

  test "format text column" do
    m = crud_test_models(:AAAAA)
    assert_equal "<p>AAAAA BBBBB CCCCC\n<br />AAAAA BBBBB CCCCC\n</p>", format_type(m, :remarks)
    assert format_type(m, :remarks).html_safe?
  end

  test "format belongs to column without content" do
    m = crud_test_models(:AAAAA)
    assert_equal t(:'global.associations.no_entry'), format_attr(m, :companion)
  end

  test "format belongs to column with content" do
    m = crud_test_models(:BBBBB)
    assert_equal "AAAAA", format_attr(m, :companion)
  end

  test "format has_many column with content" do
    m = crud_test_models(:CCCCC)
    assert_equal "<ul><li>AAAAA</li><li>BBBBB</li></ul>", format_attr(m, :others)
  end

  test "content_tag_nested escapes safe correctly" do
    html = content_tag_nested(:div, ['a', 'b']) { |e| content_tag(:span, e) }
    assert_equal "<div><span>a</span><span>b</span></div>", html
  end

  test "content_tag_nested escapes unsafe correctly" do
    html = content_tag_nested(:div, ['a', 'b']) { |e| "<#{e}>" }
    assert_equal "<div>&lt;a&gt;&lt;b&gt;</div>", html
  end

  test "content_tag_nested without block" do
    html = content_tag_nested(:div, ['a', 'b'])
    assert_equal "<div>ab</div>", html
  end

  test "safe_join without block" do
    html = safe_join(['<a>', '<b>'.html_safe])
    assert_equal "&lt;a&gt;<b>", html
  end

  test "safe_join with block" do
    html = safe_join(['a', 'b']) { |e| content_tag(:span, e) }
    assert_equal "<span>a</span><span>b</span>", html
  end

  test "empty table should render message" do
    result = table([]) { }
    assert result.html_safe?
    assert_dom_equal "<div class='table'>No entries found.</div>", result
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
      f = capture { standard_form(e, :class => 'special') {|f|} }
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
  end

  test "standard form with errors" do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?

    f = with_test_routing do
      f = capture { standard_form(e) {|f| f.labeled_input_fields(:name, :birthdate) } }
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
    assert_match /div[^>]* id='error_explanation'/, f
    assert_match /div class="control-group error"\>.*?\<input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
  end

  test "translate inheritable lookup" do
    # current controller is :crud_test_models, action is :index
    @controller = CrudTestModelsController.new

    I18n.backend.store_translations :en, :global => { :test_key => 'global' }
    assert_equal 'global', ti(:test_key)

    I18n.backend.store_translations :en, :list => {  :global => {:test_key => 'list global'} }
    assert_equal 'list global', ti(:test_key)

    I18n.backend.store_translations :en, :list => {  :index => {:test_key => 'list index'} }
    assert_equal 'list index', ti(:test_key)

    I18n.backend.store_translations :en, :crud => {  :global => {:test_key => 'crud global'} }
    assert_equal 'crud global', ti(:test_key)

    I18n.backend.store_translations :en, :crud => {  :index => {:test_key => 'crud index'} }
    assert_equal 'crud index', ti(:test_key)

    I18n.backend.store_translations :en, :crud_test_models => {  :global => {:test_key => 'test global'} }
    assert_equal 'test global', ti(:test_key)

    I18n.backend.store_translations :en, :crud_test_models => {  :index => {:test_key => 'test index'} }
    assert_equal 'test index', ti(:test_key)
  end

  test "translate association lookup" do
    assoc = CrudTestModel.reflect_on_association(:companion)

    I18n.backend.store_translations :en, :global => { :associations => {:test_key => 'global'} }
    assert_equal 'global', ta(:test_key, assoc)

    I18n.backend.store_translations :en, :activerecord => { :associations => { :crud_test_model => {:test_key => 'model'} } }
    assert_equal 'model', ta(:test_key, assoc)

    I18n.backend.store_translations :en, :activerecord => { :associations => { :models => {
    :crud_test_model => { :companion => {:test_key => 'companion'} } } } }
    assert_equal 'companion', ta(:test_key, assoc)

    assert_equal 'global', ta(:test_key)
  end

end
