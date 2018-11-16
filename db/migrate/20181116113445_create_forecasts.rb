class CreateForecasts < ActiveRecord::Migration[5.1]
  def change
    create_table :forecasts do |t|
      t.references :weather, foreign_key: true
      t.date :date
      t.float :degrees

      t.timestamps
    end
  end
end
