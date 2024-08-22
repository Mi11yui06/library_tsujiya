class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.references :catalog, null: false, foreign_key: true
      t.date :arrival_date, null:false
      t.date :disposal_date
      t.text :remarks
      t.timestamps
    end
  end
end
