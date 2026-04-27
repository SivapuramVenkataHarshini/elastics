class Products1Controller < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        product = Product1.new(payload: params[:payload])
        if product.save
            render json: product
        else
            render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def create_index
        index_name = "products1"
        if ES_CLIENT.indices.exists?(index: index_name)
            render json: { message: "Index already exists" }, status: :ok
            return
        end
        ES_CLIENT.indices.create(
            index: index_name,
            body:{
                mappings:{
                    properties:{
                        payload: { type: "object" }
                    }
                }
            }
        )
        render json:{ message:"Index created successfully" }, status: :ok
    end
    def import
        Product1.find_each do |p|
            ES_CLIENT.index(
            index: "products1",
            body: {
                payload: p.payload
            }
            )
        end
        render json: { message: "Imported successfully" }
    end
end
