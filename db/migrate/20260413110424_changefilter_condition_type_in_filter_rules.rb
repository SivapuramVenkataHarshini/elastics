class ChangefilterConditionTypeInFilterRules < ActiveRecord::Migration[8.1]
  def change
    change_column:filter_rules, :filter_condition, :string
  end
end
