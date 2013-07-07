# encoding: UTF-8
require 'spec_helper'

describe Admin::CountriesController do

  fixtures :all

  include_examples 'crud controller', skip: %w(show html plain)

  let(:test_entry)       { countries(:usa) }
  let(:test_entry_attrs) do
    { name: 'United States of America', code: 'US' }
  end

  alias_method :new_entry_attrs, :test_entry_attrs
  alias_method :edit_entry_attrs, :test_entry_attrs

  it 'should load fixtures' do
    Country.count.should == 3
  end

  describe_action :get, :index do
    it 'should be ordered by default scope' do
      entries == Country.order(:name)
    end

    it 'should set parents' do
      controller.send(:parents).should == [:admin]
    end

    it 'should set nil parent' do
      controller.send(:parent).should be_nil
    end

    it 'should use correct model_scope' do
      controller.send(:model_scope).should == Country.all
    end

    it 'should have correct path args' do
      controller.send(:path_args, 2).should == [:admin, 2]
    end
  end

  describe_action :get, :show do
    let(:params) { { id: test_entry.id } }
    it_should_redirect_to_index
  end

end
