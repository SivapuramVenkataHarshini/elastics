class CreateFilterRules < ActiveRecord::Migration[8.1]
  def change
    create_table :filter_rules do |t|
      t.string :filter_name
      t.json :filter_condition

      t.timestamps
    end
  end
end
