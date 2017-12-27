class OrderController < ApplicationController
  before_action :get_cart

  # process order
  def create
    response = Order.create_order(order_params.merge(cart_id: session[:cart_id]))

    @order, @cart = response[:order], response[:cart]

    if response[:error]
      flash[:error] = @order.errors.messages[:flash_error] if @order.errors.messages[:flash_error].present?
    else
      flash[:success] = response[:success_msg]
    end

    render :new
  end

  private

  # Using a private method to encapsulate the permissible parameters
  # is just a good pattern since you'll be able to reuse the same
  # permit list between create and update.
  def order_params
    params.require(:order).permit!
  end
end