require 'spec_helper'

describe I18nHelper do

  include CrudTestHelper

  describe "#translate_inheritable" do
    before { @controller = CrudTestModelsController.new }

    before { I18n.backend.store_translations :en, :global => { :test_key => 'global' } }
    subject { ti(:test_key) }

    it { should == 'global' }

    context "with list key" do
      before { I18n.backend.store_translations :en, :list => { :global => {:test_key => 'list global'} } }
      it { should == 'list global' }

      context "and list action key" do
        before { I18n.backend.store_translations :en, :list => { :index => {:test_key => 'list index'} } }
        it { should == 'list index' }

        context "and crud global key" do
          before { I18n.backend.store_translations :en, :crud => {  :global => {:test_key => 'crud global'} } }
          it { should == 'crud global' }

          context "and crud action key" do
            before { I18n.backend.store_translations :en, :crud => {  :index => {:test_key => 'crud index'} } }
            it { should == 'crud index' }

            context "and controller global key" do
              before { I18n.backend.store_translations :en, :crud_test_models => {  :global => {:test_key => 'test global'} } }
              it { should == 'test global' }

              context "and controller action key" do
                before { I18n.backend.store_translations :en, :crud_test_models => {  :index => {:test_key => 'test index'} } }
                it { should == 'test index' }
              end
            end
          end
        end
      end
    end
  end

  describe "#translate_association" do
    let(:assoc) { CrudTestModel.reflect_on_association(:companion) }
    subject { ta(:test_key, assoc)}

    before { I18n.backend.store_translations :en, :global => { :associations => {:test_key => 'global'} } }
    it { should == 'global' }

    context "with model key" do
      before do
        I18n.backend.store_translations :en,
            :activerecord => {
              :associations => {
                :crud_test_model => {
                  :test_key => 'model'} } }
      end

      it { should == 'model' }

      context "and assoc key" do
        before do
          I18n.backend.store_translations :en,
             :activerecord => {
               :associations => {
                 :models => {
                   :crud_test_model => {
                     :companion => {
                       :test_key => 'companion'} } } } }
        end

        it { should == 'companion' }
        it "should use global without assoc" do
          ta(:test_key).should == 'global'
        end
      end
    end
  end
end
