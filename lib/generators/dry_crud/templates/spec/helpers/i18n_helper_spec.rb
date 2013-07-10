# encoding: UTF-8
require 'spec_helper'

describe I18nHelper do

  include CrudTestHelper

  describe '#translate_inheritable' do
    before { @controller = CrudTestModelsController.new }

    before do
      I18n.backend.store_translations(
        I18n.locale,
        global: {
          test_key: 'global' })
    end
    subject { ti(:test_key) }

    it { should == 'global' }

    context 'with list key' do
      before do
        I18n.backend.store_translations(
          I18n.locale,
          list: {
            global: {
              test_key: 'list global' } })
      end
      it { should == 'list global' }

      context 'and list action key' do
        before do
          I18n.backend.store_translations(
            I18n.locale,
            list: {
              index: {
                test_key: 'list index' } })
        end
        it { should == 'list index' }

        context 'and crud global key' do
          before do
            I18n.backend.store_translations(
              I18n.locale,
              crud: {
                global: {
                  test_key: 'crud global' } })
          end
          it { should == 'crud global' }

          context 'and crud action key' do
            before do
              I18n.backend.store_translations(
                I18n.locale,
                crud: {
                  index: {
                    test_key: 'crud index' } })
            end
            it { should == 'crud index' }

            context 'and controller global key' do
              before do
                I18n.backend.store_translations(
                  I18n.locale,
                  crud_test_models: {
                    global: {
                      test_key: 'test global' } })
              end
              it { should == 'test global' }

              context 'and controller action key' do
                before do
                  I18n.backend.store_translations(
                    I18n.locale,
                    crud_test_models: {
                      index: {
                        test_key: 'test index' } })
                end
                it { should == 'test index' }
              end
            end
          end
        end
      end
    end
  end

  describe '#translate_association' do
    let(:assoc) { CrudTestModel.reflect_on_association(:companion) }
    subject { ta(:test_key, assoc) }

    before do
      I18n.backend.store_translations(
        I18n.locale,
        global: {
          associations: {
            test_key: 'global' } })
    end
    it { should == 'global' }

    context 'with model key' do
      before do
        I18n.backend.store_translations(
          I18n.locale,
          activerecord: {
            associations: {
              crud_test_model: {
                test_key: 'model' } } })
      end

      it { should == 'model' }

      context 'and assoc key' do
        before do
          I18n.backend.store_translations(
            I18n.locale,
            activerecord: {
              associations: {
                models: {
                  crud_test_model: {
                    companion: {
                      test_key: 'companion' } } } } })
        end

        it { should == 'companion' }
        it 'should use global without assoc' do
          ta(:test_key).should == 'global'
        end
      end
    end
  end
end
