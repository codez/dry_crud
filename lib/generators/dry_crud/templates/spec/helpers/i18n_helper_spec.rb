# encoding: UTF-8
require 'rails_helper'

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

    it { is_expected.to eq('global') }

    context 'with list key' do
      before do
        I18n.backend.store_translations(
          I18n.locale,
          list: {
            global: {
              test_key: 'list global' } })
      end
      it { is_expected.to eq('list global') }

      context 'and list action key' do
        before do
          I18n.backend.store_translations(
            I18n.locale,
            list: {
              index: {
                test_key: 'list index' } })
        end
        it { is_expected.to eq('list index') }

        context 'and crud global key' do
          before do
            I18n.backend.store_translations(
              I18n.locale,
              crud: {
                global: {
                  test_key: 'crud global' } })
          end
          it { is_expected.to eq('crud global') }

          context 'and crud action key' do
            before do
              I18n.backend.store_translations(
                I18n.locale,
                crud: {
                  index: {
                    test_key: 'crud index' } })
            end
            it { is_expected.to eq('crud index') }

            context 'and controller global key' do
              before do
                I18n.backend.store_translations(
                  I18n.locale,
                  crud_test_models: {
                    global: {
                      test_key: 'test global' } })
              end
              it { is_expected.to eq('test global') }

              context 'and controller action key' do
                before do
                  I18n.backend.store_translations(
                    I18n.locale,
                    crud_test_models: {
                      index: {
                        test_key: 'test index' } })
                end
                it { is_expected.to eq('test index') }
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
    it { is_expected.to eq('global') }

    context 'with model key' do
      before do
        I18n.backend.store_translations(
          I18n.locale,
          activerecord: {
            associations: {
              crud_test_model: {
                test_key: 'model' } } })
      end

      it { is_expected.to eq('model') }

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

        it { is_expected.to eq('companion') }
        it 'uses global without assoc' do
          expect(ta(:test_key)).to eq('global')
        end
      end
    end
  end
end
