require 'spec_helper'

  
describe CrudHelper do
  
  include StandardHelper
  include ListHelper
  include CrudTestHelper
  
    
  before(:all) do 
    reset_db
    setup_db
    create_test_data
  end
  
  after(:all) { reset_db }
  
  
  describe "#crud_table" do
    let(:entries) { CrudTestModel.all }
    
    context "default" do
      subject do
        with_test_routing { crud_table }
      end
      
      it "has 7 rows" do
        subject.scan(REGEXP_ROWS).size.should == 7
      end
      
      it "has 13 sort headers" do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 13
      end
      
      it "has 12 action cells" do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end
    
    context "with custom attrs" do
      subject do
        with_test_routing { crud_table(:name, :children, :companion_id) }
      end
      
      it "has 3 sort headers" do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end
    end
    
    context "with custom block" do
      subject do
        with_test_routing do
          crud_table do |t|
            t.attrs :name, :children, :companion_id
            t.col("head") {|e| content_tag :span, e.income.to_s }
          end
        end
      end
      
      it "has 4 headers" do
        subject.scan(REGEXP_HEADERS).size.should == 6
      end
      
      it "has 6 custom col spans" do
        subject.scan(/<span>.+?<\/span>/m).size.should == 6
      end
      
      it "has 12 action cells" do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end
    
    context "with custom attributes and block" do
      subject do
        with_test_routing do
          crud_table(:name, :children, :companion_id) do |t|
            t.col("head") {|e| content_tag :span, e.income.to_s }
          end
        end
      end
      
      it "has 3 sort headers" do
        subject.scan(REGEXP_SORT_HEADERS).size.should == 3
      end
      
      it "has 6 custom col spans" do
        subject.scan(/<span>.+?<\/span>/m).size.should == 6
      end
      
      it "has 12 action cells" do
        subject.scan(REGEXP_ACTION_CELL).size.should == 12
      end
    end
  end
  
  describe "#entry_form" do
    let(:entry) { CrudTestModel.first }
    subject do
      with_test_routing { entry_form }
    end
    
    it { should match /form .*?action="\/crud_test_models\/#{entry.id}"/ }
    it { should match /input .*?name="crud_test_model\[name\]" .*?type="text"/ }
    it { should match /input .*?name="crud_test_model\[whatever\]" .*?type="text"/ }
    it { should match /input .*?name="crud_test_model\[children\]" .*?type="number"/ }
    it { should match /input .*?name="crud_test_model\[rating\]" .*?type="number"/ }
    it { should match /input .*?name="crud_test_model\[income\]" .*?type="number"/ }
    it { should match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/ }
    it { should match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/ }
    it { should match /select .*?name="crud_test_model\[companion_id\]"/ }
    it { should match /textarea .*?name="crud_test_model\[remarks\]"/ }
    it { should match(/a .*href="\/crud_test_models\/#{entry.id}\?returning=true".*>Cancel<\/a>/) }
  end
  
  describe "#crud_form" do
    
    context "for existing entry" do
      subject do
        with_test_routing do
          capture do
            crud_form(entry, 
                      :name, :children, :birthdate, :human, 
                      :cancel_url => "/somewhere",
                      :html => {:class => 'special'})
          end
        end
      end
      
      let(:entry) { crud_test_models(:AAAAA) }
      
      it { should match(/form .*?action="\/crud_test_models\/#{entry.id}" .?class="special form-horizontal" .*?method="post"/) }
      it { should match(/input .*?name="_method" .*?type="hidden" .*?value="put"/) }
      it { should match(/input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/) }
      it { should match(/select .*?name="crud_test_model\[birthdate\(1i\)\]"/) }
      it { should match(/option selected="selected" value="1910">1910<\/option>/) }
      it { should match(/option selected="selected" value="1">January<\/option>/) }
      it { should match(/option selected="selected" value="1">1<\/option>/) }
      it { should match(/input .*?name="crud_test_model\[children\]" .*?type="number" .*?value=\"9\"/) }
      it { should match(/input .*?name="crud_test_model\[human\]" .*?type="checkbox"/) }
      it { should match(/button .*?type="submit">Save<\/button>/) }
      it { should match(/a .*href="\/somewhere".*>Cancel<\/a>/) }
    end
  end
  
end
