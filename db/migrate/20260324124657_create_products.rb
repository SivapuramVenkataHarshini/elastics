class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :productname
      t.decimal :price
      t.string :category

      t.timestamps
    end
  end
end
