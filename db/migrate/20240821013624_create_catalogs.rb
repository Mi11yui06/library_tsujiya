class CreateCatalogs < ActiveRecord::Migration[7.0]
  def change
    create_table :catalogs do |t|
      t.references :category, null: false, foreign_key: true
      t.string :isbn, null:false
      t.string :title, null:false
      t.string :author, null:false
      t.string :publisher, null:false
      t.date :publish_date, null:false
      t.timestamps
    end
    add_index :catalogs, [:isbn], unique: true
  end
end
