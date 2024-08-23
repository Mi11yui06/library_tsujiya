class CreateLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :loans do |t|
      t.references :member, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.date :loan_date, null:false
      t.date :due_date, null:false
      t.date :return_date
      t.text :remarks

      t.timestamps
    end
  end
end
