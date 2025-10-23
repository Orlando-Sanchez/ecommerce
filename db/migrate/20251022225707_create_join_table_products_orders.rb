class CreateJoinTableProductsOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders_products do |t|
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.jsonb :product_data, default: {}, null: false

      t.timestamps
    end

    add_index :orders_products, [ :order_id, :product_id ], unique: true
  end
end
