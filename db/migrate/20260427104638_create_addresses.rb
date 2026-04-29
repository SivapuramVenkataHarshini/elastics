class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :door_number
      t.string :street_name
      t.string :area
      t.string :city
      t.string :state
      t.string :pincode
      t.string :country

      t.timestamps
    end
  end
end
