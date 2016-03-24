# encoding: utf-8

#:nodoc:
REGEXP_ROWS = /<tr.+?<\/tr>/m #:nodoc:
REGEXP_HEADERS = /<th.+?<\/th>/m #:nodoc:
REGEXP_SORT_HEADERS = /<th.*?><a .*?sort_dir=asc.*?>.*?<\/a><\/th>/m #:nodoc:
REGEXP_ACTION_CELL = /<td class=\"action\"><a .*?href.+?<\/a><\/td>/m #:nodoc:

# A simple test helper to prepare the test database with a CrudTestModel model.
# This helper is used to test the CrudController and various helpers
# without the need for an application based model.
module CrudTestHelper

  # Controller helper methods for the tests

  def model_class
    CrudTestModel
  end

  def controller_name
    'crud_test_models'
  end

  def action_name
    'index'
  end

  def params
    {}
  end

  def path_args(entry)
    entry
  end

  def sortable?(_attr)
    true
  end

  def h(text)
    ERB::Util.h(text)
  end

  private

  # Sets up the test database with a crud_test_models table.
  # Look at the source to view the column definition.
  def setup_db
    without_transaction do
      c = ActiveRecord::Base.connection

      create_crud_test_models(c)
      create_other_crud_test_models(c)
      create_crud_test_models_other_crud_test_models(c)

      CrudTestModel.reset_column_information
    end
  end

  def create_crud_test_models(c)
    c.create_table :crud_test_models, force: true do |t|
      t.string   :name, null: false, limit: 50
      t.string   :email
      t.string   :password
      t.string   :whatever
      t.integer  :children
      t.integer  :companion_id
      t.float    :rating
      t.decimal  :income, precision: 14, scale: 4
      t.date     :birthdate
      t.time     :gets_up_at
      t.datetime :last_seen
      t.boolean  :human, default: true
      t.text     :remarks

      t.timestamps null: false
    end
  end

  def create_other_crud_test_models(c)
    c.create_table :other_crud_test_models, force: true do |t|
      t.string  :name, null: false, limit: 50
      t.integer :more_id
    end
  end

  def create_crud_test_models_other_crud_test_models(c)
    c.create_table :crud_test_models_other_crud_test_models,
                   force: true do |t|
      t.belongs_to :crud_test_model, index: { name: 'parent' }
      t.belongs_to :other_crud_test_model, index: { name: 'other' }
    end
  end

  # Removes the crud_test_models table from the database.
  def reset_db
    c = ActiveRecord::Base.connection
    [:crud_test_models,
     :other_crud_test_models,
     :crud_test_models_other_crud_test_models].each do |table|
      c.drop_table(table) if c.data_source_exists?(table)
    end
  end

  # Creates 6 dummy entries for the crud_test_models table.
  def create_test_data
    (1..6).reduce(nil) { |a, e| create(e, a) }
    (1..6).each { |i| create_other(i) }
  end

  # Fixture-style accessor method to get CrudTestModel instances by name
  def crud_test_models(name)
    CrudTestModel.find_by_name(name.to_s)
  end

  def with_test_routing
    with_routing do |set|
      set.draw { resources :crud_test_models }
      # used to define a controller in these tests
      set.default_url_options = { controller: 'crud_test_models' }
      yield
    end
  end

  def special_routing
    # test:unit uses instance variable, rspec the method
    controller = @controller || @_controller || controller
    @routes = ActionDispatch::Routing::RouteSet.new
    routes = @routes

    controller.singleton_class.send(:include, routes.url_helpers)
    controller.view_context_class = Class.new(controller.view_context_class) do
      include routes.url_helpers
    end

    @routes.draw { resources :crud_test_models }
  end

  def create(index, companion)
    c = str(index)
    m = CrudTestModel.new(
      name: c,
      children: 10 - index,
      rating: "#{index}.#{index}".to_f,
      income: 10_000_000 * index + 0.1111 * index,
      birthdate: "#{1900 + 10 * index}-#{index}-#{index}",
      # store entire date to avoid time zone issues
      gets_up_at: Time.zone.local(2000, 1, 1, index, index),
      last_seen: "#{2000 + 10 * index}-#{index}-#{index} " \
                 "1#{index}:2#{index}",
      human: index.even?,
      remarks: "#{c} #{str(index + 1)} #{str(index + 2)}\n" *
                  (index % 3 + 1))
    m.companion = companion
    m.save!
    m
  end

  def create_other(index)
    c = str(index)
    others = CrudTestModel.all[index..(index + 2)]
    OtherCrudTestModel.create!(name: c,
                               other_ids: others.map(&:id),
                               more_id: others.first.try(:id))
  end

  def str(index)
    (index + 64).chr * 5
  end

  # A hack to avoid ddl in transaction issues with mysql.
  def without_transaction
    c = ActiveRecord::Base.connection
    start_transaction = false
    if c.adapter_name.downcase.include?('mysql') && c.open_transactions > 0
      # in transactional tests, we may simply rollback
      c.execute('ROLLBACK')
      start_transaction = true
    end

    yield

    c.execute('BEGIN') if start_transaction
  end

end
