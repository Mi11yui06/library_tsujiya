class CreateMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :members do |t|
      t.string :name, null:false
      t.string :post_code, null:false
      t.string :address, null:false
      t.string :tel, null:false
      t.string :email, null:false
      t.date :birth_date, null:false
      t.date :join_date, null:false
      t.date :remove_date
      t.timestamps
    end
    add_index :members, [:email], unique: true
  end
end
