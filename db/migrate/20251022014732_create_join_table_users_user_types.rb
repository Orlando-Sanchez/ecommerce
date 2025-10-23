class CreateJoinTableUsersUserTypes < ActiveRecord::Migration[8.0]
  def change
    create_join_table :users, :user_types do |t|
      t.index [ :user_id, :user_type_id ], unique: true
    end
  end
end
