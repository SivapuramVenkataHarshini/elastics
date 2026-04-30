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
            session[:user_id] = user.id
            merge_guest_cart(user)
            render json: { message: "Verification successful"}
        else
            render json: { error: "USER not found"},status: :not_found
        end
    end
    def merge_guest_cart(user)
        guest_cart = Cart.find_by(guest_id: cookies.signed[:guest_id], status: 0)
        user_cart = Cart.find_or_create_by(user_id: user.id, status: 0)
        return unless guest_cart
        if guest_cart
            guest_cart.cart_items.each do |guest_item|
                existing_item = user_cart.cart_items.find_by(product1_id: guest_item.product1_id)

                if existing_item
                    existing_item.update!(
                        quantity: existing_item.quantity + guest_item.quantity
                    )
                else
                    guest_item.update!(cart_id: user_cart.id)
                end
            end
        end
        guest_cart.destroy
    end
    def login
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
            if user.is_verified
                session[:user_id] = user.id
                merge_guest_cart(user)
                render json: {message: "user logged in successfully"}
            else
                render json: {error: "please verify yoyur account before the login"}
            end
        else
            render json: {error: "Invalid email or password "}
        end
    end

    def logout
        session[:user_id] = nil
        render json: { message: "Logged out successfully" }
    end
    private
    def user_params
        params.require(:user).permit(:name, :email, :password, :country_code, :phone_number)
    end
end
