class CreateStarts < ActiveRecord::Migration
  def change
    create_table :starts do |t|
      t.integer :category_id
      t.integer :start

      t.timestamps
    end
  end
end
