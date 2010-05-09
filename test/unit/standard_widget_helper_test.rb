require 'test_helper'

class StandardWidgetHelperTest < ActionView::TestCase

	include StandardWidgetHelper
	
	test "labeled text" do
		result = labeled("label") { "value" }
		
		assert_dom_equal "<span class='labeled'><label>label</label><span>value</span></span>", result
	end
	
	test "alternate row" do
		result_1 = tr_alternate { "(test row content)" }
		result_2 = tr_alternate { "(test row content)" }

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
	
	test "empty list should render message" do
		assert_dom_equal "<div class='list'>#{NO_LIST_ENTRIES_MESSAGE}</div>", list([]) { }
	end	
	
	test "two x two list" do
		dom = <<-FIN
			<table class="list">
			<tr><th>Upcase</th><th>Size</th></tr>
			<tr class="even"><td>FOO</td><td>3</td></tr>
			<tr class="odd"><td>BAHR</td><td>4</td></tr>
			</table>
		FIN
		
		assert_dom_equal dom, list(["foo", "bahr"]) { |l| l.attrs [:upcase, :size] }
	end
	
	test "list with before and after cells" do 
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
		
		result = list(["foo", "bahr"]) do |l| 
			l.col('head', :class => 'left') { |e| link_to e, "/" }
			l.attrs [:upcase, :size]
			l.col { |e| "Never #{e}" }
		end
		
		assert_dom_equal dom, result
	end
	

end