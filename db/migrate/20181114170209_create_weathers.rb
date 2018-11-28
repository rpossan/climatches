class CreateWeathers < ActiveRecord::Migration[5.1]
  def change
    create_table :weathers do |t|
      t.string :city
      t.integer :city_id
      t.integer :temperature
      t.decimal :lat, precision: 6, scale: 2
      t.decimal :lon, precision: 6, scale: 2

      t.timestamps
    end
  end
end
