class ChangeNameNullAndUniqueInUserTypes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_types, :name, false

    add_index :user_types, :name, unique: true
  end
end
