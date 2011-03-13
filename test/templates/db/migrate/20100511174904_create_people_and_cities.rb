class CreatePeopleAndCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string :name, :null => false
      t.string :country_code, :null => false, :limit => 3
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
    end
  end

  def self.down
    drop_table :people
    drop_table :cities
  end
end
