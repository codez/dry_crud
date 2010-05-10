require 'test_helper'

class StandardTableBuilderTest < ActionView::TestCase
  
  # set dummy helper class for ActionView::TestCase
  self.helper_class = StandardHelper
  
  attr_reader :table
  
  def setup
    @table = StandardTableBuilder.new(["foo", "bahr"], self)
  end
  
  test "html header" do
    dom = <<-FIN
      <tr><th>Upcase</th><th>Size</th></tr>
    FIN
    table.attrs :upcase, :size
    
    assert_dom_equal dom, table.html_header
  end

  test "single attr row" do
    table.attrs :upcase, :size
    
    dom = <<-FIN
      <tr class="even"><td>FOO</td><td>3</td></tr>
    FIN
    
    assert_dom_equal dom, table.html_row("foo")
  end
  
  test "custom row" do
    table.col("Header", :class => 'hula') {|e| "Weights #{e.size} kg" }
        
    dom = <<-FIN
      <tr class="even"><td class='hula'>Weights 3 kg</td></tr>
    FIN
    
    assert_dom_equal dom, table.html_row("foo")
  end
  
  test "attr col output" do
    table.attrs :upcase
    col = table.cols.first
    
    assert_equal "<th>Upcase</th>", col.html_header
    assert_equal "FOO", col.content("foo")
    assert_equal "<td>FOO</td>", col.html_cell("foo")
  end
	
	test "two x two table" do
		dom = <<-FIN
			<table class="list">
			<tr><th>Upcase</th><th>Size</th></tr>
			<tr class="even"><td>FOO</td><td>3</td></tr>
			<tr class="odd"><td>BAHR</td><td>4</td></tr>
			</table>
		FIN
    
    table.attrs :upcase, :size
    
		assert_dom_equal dom, table.to_html
	end
	
	test "table with before and after cells" do 
		dom = <<-FIN
			<table class="list">
			<tr><th>head</th><th>Upcase</th><th>Size</th><th></th></tr>
			<tr class="even">
				<td class='left'><a href='/'>foo</a></td>
				<td>FOO</td>
				<td>3</td>
				<td>Never foo</td>
			</tr>
			<tr class="odd">
				<td class='left'><a href='/'>bahr</a></td>
				<td>BAHR</td>
				<td>4</td>
				<td>Never bahr</td>
			</tr>
			</table>
		FIN
		
	  table.col('head', :class => 'left') { |e| link_to e, "/" }
	  table.attrs :upcase, :size
	  table.col { |e| "Never #{e}" }
		
		assert_dom_equal dom, table.to_html
	end
	

end