class RemovefilterCondition2FromFilterRules < ActiveRecord::Migration[8.1]
  def change
    remove_column :filter_rules, :filter_condition2, :string
  end
end
