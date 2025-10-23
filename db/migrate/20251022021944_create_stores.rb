class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
