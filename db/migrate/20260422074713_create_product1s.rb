class CreateProduct1s < ActiveRecord::Migration[8.1]
  def change
    create_table :product1s do |t|
      t.json :payload

      t.timestamps
    end
  end
end
