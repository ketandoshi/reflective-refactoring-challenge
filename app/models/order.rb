class Order < ActiveRecord::Base
  # Callback methods
  after_create :after_create_order

  # Define attribute because we will need it in after_create method
  attr_accessor :cart_id

  def self.create_order(params)
    order_response = {error: false}

    order = Order.new(params)

    # assign cart_id attribute
    order.cart_id = params[:cart_id]

    cart = get_cart

    # Add items from cart to order's ordered_items association
    cart.ordered_items.each do |item|
      order.ordered_items << item
    end

    # Add shipping and tax to order total
    # To update the total attribute of order object, call an instance method in orders model.
    order.add_shipping_fees(params)
    order.add_tax

    # Process credit card
    credit_card_response = CreditCard.new(params.merge(order_total: order.total)).make_purchase

    if credit_card_response[:error].present?
      order.errors.add(:error, credit_card_response[:error])
      order.errors.add(:flash_error, credit_card_response[:flash_error]) if credit_card_response[:flash_error].present?
      order_response.store(:error, true)
    end

    return order_response.merge(cart: cart, order: order) if order_response[:error]

    order.order_status = 'processed'

    if order.save
      order_response.store(:success_msg, "You successfully ordered!")
    else
      order.errors.add(:flash_error, "There was a problem processing your order. Please try again.")
      order_response.store(:error, true)
    end

    order_response.merge!(cart: cart, order: order)

    order_response
  end

  def get_cart
    Cart.find(self.cart_id) rescue ActiveRecord::RecordNotFound
  end

  def add_shipping_fees(params)
    self.total ||= 0.0
    self.total += Shipping.get_shipping_charge(params[:order][:shipping_method])
  end

  def add_tax
    self.total ||= 0.0
    self.total += self.taxed_total
  end

  private

  def after_create_order
    # get rid of cart
    Cart.destroy(self.cart_id)
    # send order confirmation email
    OrderMailer.order_confirmation(self.billing_email, self.id).deliver
  end
end