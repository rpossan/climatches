class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.references :playlist_id, foreign_key: false
      t.string :name

      t.timestamps
    end
  end
end
