class AddCategotyNameToStart < ActiveRecord::Migration
  def change
    add_column :starts, :category_name, :string
  end
end
