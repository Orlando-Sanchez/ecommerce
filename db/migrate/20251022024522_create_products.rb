class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :quantity, null: false
      t.decimal :price, null: false, precision: 10, scale: 2
      t.integer :status, null: false, default: 0
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
