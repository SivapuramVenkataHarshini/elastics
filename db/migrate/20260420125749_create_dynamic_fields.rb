class CreateDynamicFields < ActiveRecord::Migration[8.1]
  def change
    create_table :dynamic_fields do |t|
      t.string :field_name
      t.string :field_type

      t.timestamps
    end
  end
end
