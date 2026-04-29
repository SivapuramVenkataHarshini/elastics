class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :product1, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.integer :price_at_time, precision: 8, scale: 2

      t.timestamps
    end
  end
end
