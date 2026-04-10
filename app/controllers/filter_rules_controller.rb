class FilterRulesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        @rule = FilterRule.new(rule_params)
        if @rule.save
        render json: { message: "Rule created successfully", data: @rule }, status: :created
        else
        render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
        end
    end
    def index
        @rules=FilterRule.all
        render json: {
        count: @rules.count,
        rules: @rules.map do |rule|
            {
                id: rule.id,
                name: rule.filter_name,
                condition: rule.filter_condition
            }
        end
        }
    end
    
    private

    def rule_params
        # Permit filter_name and allow filter_condition to be a deep hash
        params.require(:filter_rule).permit(:filter_name, filter_condition: {})
    end
end
