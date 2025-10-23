class ChangeDescriptionNullInOrganizations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organizations, :description, false
  end
end
