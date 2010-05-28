class CrudTestModel < ActiveRecord::Base #:nodoc:
  default_scope :order => 'name'
  
  belongs_to :companion, :class_name => 'CrudTestModel'
  
  def label
    name
  end
end

class CrudTestModelsController < CrudController #:nodoc:
  before_create :handle_name
  
  def handle_name
    if @entry.name == 'illegal'
      flash[:error] = "illegal name"
      return false
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :crud_test_models
end

module CrudTestHelper

  protected 
  
  def setup_db    
    silence_stream(STDOUT) do
        ActiveRecord::Base.connection.create_table :crud_test_models, :force => true do |t|
          t.string  :name, :null => false, :limit => 50
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
  end
  
  def reset_db
    [:crud_test_models].each do |table|            
      ActiveRecord::Base.connection.drop_table(table) rescue nil
    end
  end
  
  def create_test_data
    (1..6).inject(nil) {|prev, i| create(i, prev) }
  end
  
  def crud_test_models(name)
    CrudTestModel.find_by_name(name.to_s)
  end
  
  private
  
  def create(index, companion)
    c = (index + 64).chr * 5
    CrudTestModel.create!(:name => c, 
                          :children => index, 
                          :companion => companion,
                          :rating => "#{index}.#{index}".to_f, 
                          :income => 10000000 * index + 0.1 * index, 
                          :birthdate => '#{index}-#{index}-#{1900 + 10 * index}', 
                          :human => index % 2 == 0,
                          :remarks => "#{c} #{c} #{c}\n" * 3)
  end
  
end