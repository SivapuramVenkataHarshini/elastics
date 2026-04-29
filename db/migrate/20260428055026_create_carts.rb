class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :user, null: true, foreign_key: true
      t.string :guest_id
      t.integer :status

      t.timestamps
    end
  end
end
