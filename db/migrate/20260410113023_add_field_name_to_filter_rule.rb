class AddFieldNameToFilterRule < ActiveRecord::Migration[8.1]
  def change
    add_column :filter_rules, :filter_condition2, :string
  end
end
