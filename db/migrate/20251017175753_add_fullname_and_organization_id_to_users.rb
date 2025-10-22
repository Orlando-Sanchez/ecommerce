class AddFullnameAndOrganizationIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :fullname, :string
    add_reference :users, :organization, null: true, foreign_key: true
  end
end
