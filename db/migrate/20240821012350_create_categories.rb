class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.integer :code, null:false
      t.string :name, null:false
    end
  end
end
