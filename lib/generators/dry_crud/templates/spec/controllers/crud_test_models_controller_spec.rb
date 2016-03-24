# encoding: UTF-8
require 'rails_helper'

# Tests all actions of the CrudController based on a dummy model
# (CrudTestModel). This is useful to test the general behavior
# of CrudController.

describe CrudTestModelsController do
  include CrudTestHelper

  before(:all) do
    reset_db
    setup_db
    create_test_data
  end

  after(:all) { reset_db }

  before { special_routing }

  include_examples 'crud controller', {}

  let(:test_entry) { crud_test_models(:AAAAA) }
  let(:new_entry_attrs) do
    { name: 'foo',
      children: 42,
      companion_id: 3,
      rating: 8.5,
      income: 2.42,
      birthdate: '31-12-1999'.to_date,
      human: true,
      remarks: "some custom\n\tremarks" }
  end
  let(:edit_entry_attrs) do
    { name: 'foo',
      children: 42,
      rating: 8.5,
      income: 2.42,
      birthdate: '31-12-1999'.to_date,
      human: true,
      remarks: "some custom\n\tremarks" }
  end

  describe 'setup' do
    it 'model count is correct' do
      expect(CrudTestModel.count).to eq(6)
    end

    it 'has models_label' do
      expect(controller.models_label).to eq('Crud Test Models')
    end

    it 'has models_label singular' do
      expect(controller.models_label(false)).to eq('Crud Test Model')
    end
  end

  describe_action :get, :index do
    context '.html', format: :html do
      context 'plain', combine: 'ihp' do
        it 'contains all entries' do
          expect(entries.size).to eq(6)
        end

        it 'session has empty list_params' do
          expect(session[:list_params]).to eq({})
        end

        it 'provides entries helper method' do
          expect(entries).to be(controller.send(:entries))
        end
      end

      context 'search' do
        let(:params) { { q: search_value } }

        context 'regular', combine: 'ihse' do
          it 'entries only contain test_entry' do
            expect(entries).to eq([test_entry])
          end

          it 'session has query list param' do
            expect(session[:list_params]['/crud_test_models.html'])
              .to eq('q' => 'AAAA')
          end
        end

        context 'with custom options', combine: 'ihsec' do
          let(:params) { { q: 'DDD', filter: true } }

          it_is_expected_to_respond

          it 'entries have one item' do
            expect(entries).to eq([CrudTestModel.find_by_name('BBBBB')])
          end

          it 'session has query list param' do
            expect(session[:list_params]['/crud_test_models.html'])
              .to eq('q' => 'DDD')
          end
        end
      end

      context 'sort' do
        context 'for given column', combine: 'ihsog' do
          let(:params) { { sort: 'children', sort_dir: 'asc' } }

          it_is_expected_to_respond

          it 'entries are in correct order' do
            expect(entries).to eq(CrudTestModel.all.sort_by(&:children))
          end

          it 'session has sort list param' do
            expect(session[:list_params]['/crud_test_models.html']).to eq(
              'sort' => 'children', 'sort_dir' => 'asc')
          end
        end

        context 'for virtual column', combine: 'ihsov' do
          let(:params) { { sort: 'chatty', sort_dir: 'desc' } }

          it_is_expected_to_respond

          it 'entries are in correct order' do
            names = entries.map(&:name)
            assert names.index('BBBBB') < names.index('AAAAA')
            assert names.index('BBBBB') < names.index('DDDDD')
            assert names.index('EEEEE') < names.index('AAAAA')
            assert names.index('EEEEE') < names.index('DDDDD')
            assert names.index('AAAAA') < names.index('CCCCC')
            assert names.index('DDDDD') < names.index('CCCCC')
          end

          it 'session has sort list param' do
            expect(session[:list_params]['/crud_test_models.html']).to eq(
              'sort' => 'chatty', 'sort_dir' => 'desc')
          end
        end

        context 'with search', combine: 'ihsose' do
          let(:params) do
            { q: 'DDD', sort: 'chatty', sort_dir: 'asc' }
          end

          it_is_expected_to_respond

          it 'entries are in correct order' do
            expect(entries.map(&:name)).to eq(%w(CCCCC DDDDD BBBBB))
          end

          it 'session has sort list param' do
            expect(session[:list_params]['/crud_test_models.html']).to eq(
              'q' => 'DDD', 'sort' => 'chatty', 'sort_dir' => 'asc')
          end
        end
      end

      context 'with custom options', combine: 'ihsoco' do
        let(:params) { { filter: true } }

        it_is_expected_to_respond

        context 'entries' do
          subject { entries }
          it { expect(subject.size).to eq(2) }
          it { is_expected.to eq(entries.sort_by(&:children).reverse) }
        end
      end

      context 'returning', perform_request: false do
        before do
          session[:list_params] = {}
          session[:list_params]['/crud_test_models'] =
            { 'q' => 'DDD', 'sort' => 'chatty', 'sort_dir' => 'desc' }
          get :index, params: { returning: true }
        end

        it_is_expected_to_respond

        it 'entries are in correct order' do
          expect(entries.map(&:name)).to eq(%w(BBBBB DDDDD CCCCC))
        end

        it 'params are set' do
          expect(controller.params[:q]).to eq('DDD')
          expect(controller.params[:sort]).to eq('chatty')
          expect(controller.params[:sort_dir]).to eq('desc')
        end
      end
    end

    context '.js', format: :js, combine: 'ijs' do
      it_is_expected_to_respond
      it { expect(response.body).to eq('index js') }
    end
  end

  describe_action :get, :new do
    context 'plain', combine: 'new' do
      it 'assigns companions' do
        expect(ivar(:companions)).to be_present
      end

      it 'calls two render callbacks' do
        expect(controller.called_callbacks).to eq(
          [:before_render_new, :before_render_form])
      end
    end

    context 'with before_render callback redirect',
            perform_request: false do
      before do
        controller.should_redirect = true
        get :new
      end

      it { is_expected.to redirect_to(crud_test_models_path) }

      it 'does not set companions' do
        expect(ivar(:companions)).to be_nil
      end
    end
  end

  describe_action :post, :create do
    let(:params) { { model_identifier => new_entry_attrs } }

    it 'calls the correct callbacks' do
      expect(controller.called_callbacks).to eq(
        [:before_create, :before_save, :after_save, :after_create])
    end

    context 'with before callback' do
      let(:params) do
        { crud_test_model: { name: 'illegal', children: 2 } }
      end
      it 'does not create entry', perform_request: false do
        expect { perform_request }.to change { CrudTestModel.count }.by(0)
      end

      context 'plain', combine: 'chcp' do
        it_is_expected_to_respond
        it_is_expected_to_persist_entry(false)
        it_is_expected_to_have_flash(:alert)

        it 'sets entry name' do
          expect(entry.name).to eq('illegal')
        end

        it 'assigns companions' do
          expect(ivar(:companions)).to be_present
        end

        it 'calls the correct callbacks' do
          expect(controller.called_callbacks).to eq(
            [:before_render_new, :before_render_form])
        end
      end

      context 'redirect', perform_request: false do
        before { controller.should_redirect = true }

        it 'does not create entry' do
          expect { perform_request }.to change { CrudTestModel.count }.by(0)
        end

        it do
          perform_request
          is_expected.to redirect_to(crud_test_models_path)
        end

        it 'calls no callbacks' do
          perform_request
          expect(controller.called_callbacks).to be_nil
        end
      end
    end

    context 'with invalid params' do
      let(:params) { { crud_test_model: { children: 2 } } }

      context '.html' do
        it 'does not create entry', perform_request: false do
          expect { perform_request }.to change { CrudTestModel.count }.by(0)
        end

        context 'plain', combine: 'chip' do
          it_is_expected_to_respond
          it_is_expected_to_persist_entry(false)
          it_is_expected_to_not_have_flash(:notice)
          it_is_expected_to_not_have_flash(:alert)

          it 'assigns companions' do
            expect(ivar(:companions)).to be_present
          end

          it 'calls the correct callbacks' do
            expect(controller.called_callbacks).to eq(
              [:before_create, :before_save,
               :before_render_new, :before_render_form])
          end
        end
      end

      context '.json', format: :json do
        it 'does not create entry', perform_request: false do
          expect { perform_request }.to change { CrudTestModel.count }.by(0)
        end

        context 'plain', combine: 'cjcb' do
          it_is_expected_to_respond(422)
          it_is_expected_to_persist_entry(false)
          it_is_expected_to_not_have_flash(:notice)
          it_is_expected_to_not_have_flash(:alert)
          it_is_expected_to_render_json

          it 'does not assign companions' do
            expect(ivar(:companions)).to be_nil
          end

          it 'calls the correct callbacks' do
            expect(controller.called_callbacks).to eq(
              [:before_create, :before_save])
          end
        end
      end
    end
  end

  describe_action :get, :edit, id: true do
    it 'calls the correct callbacks' do
      expect(controller.called_callbacks).to eq(
        [:before_render_edit, :before_render_form])
    end
  end

  describe_action :put, :update, id: true do
    let(:params) { { model_identifier => edit_entry_attrs } }

    it 'calls the correct callbacks' do
      expect(controller.called_callbacks).to eq(
        [:before_update, :before_save, :after_save, :after_update])
    end

    context 'with invalid params' do
      let(:params) { { crud_test_model: { rating: 20 } } }

      context '.html', combine: 'uhivp' do
        it_is_expected_to_respond
        it_is_expected_to_not_have_flash(:notice)

        it 'changes entry' do
          expect(entry).to be_changed
        end

        it 'sets entry rating' do
          expect(entry.rating).to eq(20)
        end

        it 'calls the correct callbacks' do
          expect(controller.called_callbacks).to eq(
            [:before_update, :before_save,
             :before_render_edit, :before_render_form])
        end
      end

      context '.json', format: :json, combine: 'ujivp' do
        it_is_expected_to_respond(422)
        it_is_expected_to_not_have_flash(:notice)
        it_is_expected_to_render_json

        it 'calls the correct callbacks' do
          expect(controller.called_callbacks).to eq(
            [:before_update, :before_save])
        end
      end
    end
  end

  describe_action :delete, :destroy, id: true do
    it 'calls the correct callbacks' do
      expect(controller.called_callbacks).to eq(
        [:before_destroy, :after_destroy])
    end

    context 'with failure' do
      let(:test_entry) { crud_test_models(:BBBBB) }
      context '.html' do
        it 'does not delete entry from database',
           perform_request: false do
          expect { perform_request }.not_to change { CrudTestModel.count }
        end

        it 'redirects to referer',
           perform_request: false do
          ref = @request.env['HTTP_REFERER'] = crud_test_model_url(test_entry)
          perform_request
          is_expected.to redirect_to(ref)
        end

        it_is_expected_to_have_flash(:alert, /companion/)
        it_is_expected_to_not_have_flash(:notice)
      end

      context '.json', format: :json, combine: 'djf' do
        it_is_expected_to_respond(422)
        it_is_expected_to_not_have_flash(:notice)
        it_is_expected_to_render_json
      end

      context 'callback', perform_request: false do
        before do
          test_entry.update_attribute :name, 'illegal'
        end

        it 'does not delete entry from database' do
          expect { perform_request }.not_to change { CrudTestModel.count }
        end

        it 'redirects to index' do
          perform_request
          is_expected.to redirect_to(crud_test_models_path(returning: true))
        end

        it 'has flash alert' do
          perform_request
          expect(flash[:alert]).to match(/illegal name/)
        end
      end
    end
  end
end
