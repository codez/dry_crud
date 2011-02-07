# A dummy model used for general testing.
class CrudTestModel < ActiveRecord::Base #:nodoc:

  belongs_to :companion, :class_name => 'CrudTestModel'
  
  validates :name, :presence => true
  validates :rating, :inclusion => { :in => 1..10 }
  
  default_scope order('name') 
  
  def label
    name
  end
  
  def chatty
  	remarks.size
  end
end

# Controller for the dummy model.
class CrudTestModelsController < CrudController #:nodoc:
  HANDLE_PREFIX = 'handle_'
  
  self.search_columns = [:name, :whatever, :remarks]
  self.sort_mappings = {:chatty => 'length(remarks)'}
  
  before_create :possibly_redirect
  before_create :handle_name
  
  before_render_new :possibly_redirect
  before_render_new :set_companions
  
  attr_reader :called_callbacks
  attr_accessor :should_redirect
  
  hide_action :called_callbacks, :should_redirect, :should_redirect=
  
  # don't use the standard layout as it may require different routes
  # than just the test route for this controller
  layout nil
  
  protected
  
  def list_entries
    entries = super
  	if params[:filter]
  	  entries = entries.where(['rating < ?', 3]).except(:order).order('children DESC')
    end
    entries
  end
  
  private
  
  # custom callback
  def handle_name
    if @entry.name == 'illegal'
      flash[:error] = "illegal name"
      return false
    end
  end
  
  # create callback methods that record the before/after callbacks
  [:create, :update, :save, :destroy].each do |a|
    callback = "before_#{a.to_s}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
    callback = "after_#{a.to_s}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
  end
  
  # create callback methods that record the before_render callbacks
  [:index, :show, :new, :edit, :form].each do |a|
    callback = "before_render_#{a.to_s}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
  end
  
  # handle the called callbacks
  def method_missing(sym, *args)
    called_callback(sym.to_s[HANDLE_PREFIX.size..-1].to_sym) if sym.to_s.starts_with?(HANDLE_PREFIX)
  end
  
  # callback to redirect if @should_redirect is set
  def possibly_redirect
    redirect_to :action => 'index' if should_redirect && !performed?
    !should_redirect
  end
  
  def set_companions
    @companions = CrudTestModel.all :conditions => {:human => true}
  end
  
  # records a callback
  def called_callback(callback)
    @called_callbacks ||= []
    @called_callbacks << callback
  end
  
end

# A simple test helper to prepare the test database with a CrudTestModel model.
# This helper is used to test the CrudController and various helpers
# without the need for an application based model.
module CrudTestHelper

  protected 
  
  # Sets up the test database with a crud_test_models table.
  # Look at the source to view the column definition.
  def setup_db    
    without_transaction do
      silence_stream(STDOUT) do
        ActiveRecord::Base.connection.create_table :crud_test_models, :force => true do |t|
          t.string  :name, :null => false, :limit => 50
          t.string  :password
          t.string  :whatever
          t.integer :children
          t.integer :companion_id
          t.float   :rating
          t.decimal :income, :precision => 14, :scale => 2
          t.date    :birthdate
          t.boolean :human, :default => true
          t.text    :remarks
          
          t.timestamps
        end
      end
          
      CrudTestModel.reset_column_information
    end
  end
  
  # Removes the crud_test_models table from the database.
  def reset_db
    c = ActiveRecord::Base.connection
    [:crud_test_models].each do |table|            
      if c.table_exists?(table)
        c.drop_table(table) rescue nil
      end
    end
  end
  
  # Creates 6 dummy entries for the crud_test_models table.
  def create_test_data
    (1..6).inject(nil) {|prev, i| create(i, prev) }
  end
  
  # Fixture-style accessor method to get CrudTestModel instances by name
  def crud_test_models(name)
    CrudTestModel.find_by_name(name.to_s)
  end
    
  def with_test_routing
    with_routing do |set|
      set.draw { resources :crud_test_models }
      # used to define a controller in these tests
      set.default_url_options = {:controller => 'crud_test_models'}
      yield
    end
  end
  
  
  private
  
  def create(index, companion)
    c = str(index)
    CrudTestModel.create!(:name => c, 
                          :children => 10 - index, 
                          :companion => companion,
                          :rating => "#{index}.#{index}".to_f, 
                          :income => 10000000 * index + 0.1 * index, 
                          :birthdate => "#{1900 + 10 * index}-#{index}-#{index}", 
                          :human => index % 2 == 0,
                          :remarks => "#{c} #{str(index + 1)} #{str(index + 2)}\n" * (index % 3 + 1))
  end
  
  def str(index)
     (index + 64).chr * 5
  end
  
  # hack to avoid ddl in transaction issues with mysql.
  def without_transaction
    c = ActiveRecord::Base.connection
    start_transaction = false
    if c.adapter_name.downcase.include?('mysql') && c.open_transactions > 0
      # in transactional tests, we may simply rollback
      c.execute("ROLLBACK")
      start_transaction = true
    end
    
    yield    
    
    c.execute("BEGIN") if start_transaction
  end

end
