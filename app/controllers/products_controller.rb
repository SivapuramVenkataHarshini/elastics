class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        data=Product.create(user_params)
        
        render json: data
    end

    def adding
        Product.add_product
        render json: { message: "Sync started" }
    end

    def updating
        @product = Product.find(params[:id]) 
        if @product.update_with_elasticsearch(user_params)
            render json: @product
        else
            render json: { errors: "Update failed" }, status: :unprocessable_entity
        end
    end

    def deleting
        @product = Product.find(params[:id])
        if @product.delete_with_elasticsearch
            render json: { message: "Deleted" }
        else
            render json: { error: "Delete failed" }, status: :error
        end
    end

    def index
        render json: Product.all
    end

    private
    def user_params
        params.permit(:productname, :price, :category)
    end
end
