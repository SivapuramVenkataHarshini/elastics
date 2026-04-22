class DynamicFieldsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        data = DynamicField.create(user_params)       
        render json: data
    end
    private 
    def user_params
        params.permit(:field_name, :field_type)
    end
end
