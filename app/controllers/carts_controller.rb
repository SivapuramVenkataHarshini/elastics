class CartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def current_cart
    if current_user
      Cart.find_or_create_by(user_id: current_user.id, status: 0)
    else
      Cart.find_or_create_by(
      guest_id: cookies.signed[:guest_id],
      status: 0
    )
    end
  end

  def add_to_cart
    cart = current_cart
    product = Product1.find(params[:id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity <= 0
    cart_item = cart.cart_items.find_by(product1_id: product.id)
    if cart_item
      cart_item.update!(quantity: cart_item.quantity + quantity)
    else
      cart_item = cart.cart_items.create!(
        product1_id: product.id,
        quantity: quantity,
        price_at_time: product.payload["price"]
      )
    end
    render json: { message: "ok", quantity: cart_item.quantity }
  end
  
  def show_cart
    cart = current_cart
    value = 0
    items = cart.cart_items.includes(:product1).map do |item|
        {
          product_name: item.product1.payload["productname"],
          price: item.price_at_time,
          quantity: item.quantity,
          total: item.quantity * item.price_at_time.to_f,
        }
    end
    total_value = items.sum {|v| v[:total]}
    render json: {
      cart: cart,
      items: items,
      total_value: total_value
    }
  end
end