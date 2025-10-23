class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :store, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    
    add_index :invoices, [:store_id, :order_id], unique: true
  end
end
