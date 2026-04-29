class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
        user = User.new(user_params)
        if user.save
            render json: { message:"User account craeted . please verify the account" }
        else
            render json: { errors:user.errors.full_messages},status: :unprocessable_entity
        end
    end

    def index
        render json: User.all
    end

    def verify
        user = User.find_by(email: params[:email])
        if user
            user.update(is_verified: true)
            render json: { message: "Verification successful"}
        else
            render json: { error: "USER not found"},status: :not_found
        end
    end
    
    def login
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
            if user.is_verified
                render json: {message: "user logged in successfully"}
            else
                render json: {error: "please verify yoyur account before the login"}
            end
        else
            render json: {error: "Invalid email or password "}
        end
    end

    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :country_code, :phone_number)
    end
end
