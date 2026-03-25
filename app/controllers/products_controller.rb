class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        data=Product.create(user_params)
        
        render json: data
    end
    

    def index
        render json: Product.all
    end

    private
    def user_params
        params.require(:practice).permit(:productname, :price, :category)
    end
end
