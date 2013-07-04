# encoding: UTF-8

# initial migration
class CreatePeopleAndCities < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name, :null => false
      t.string :code, :null => :false, :limit => 3
    end

    create_table :cities do |t|
      t.string :name, :null => false
      t.integer :country_id, :null => false
    end

    create_table :people do |t|
      t.string :name, :null => false
      t.integer :children
      t.integer :city_id
      t.float :rating
      t.decimal :income, :precision => 14, :scale => 2
      t.date :birthdate
      t.time :gets_up_at
      t.datetime :last_seen
      t.text :remarks
      t.boolean :cool, :null => false, :default => false
      t.string :email
      t.string :password
    end
  end
end
