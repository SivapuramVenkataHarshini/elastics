class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :country_code
      t.string :phone_number
      t.boolean :is_verified, default: false, null: false

      t.timestamps
    end
  end
end
