# All the credit card related functionality should happen from here only.
#
class CreditCard
  # Create a connection to ActiveMerchant
  gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
    login: ENV["AUTHORIZE_LOGIN"],
    password: ENV["AUTHORIZE_PASSWORD"]
  )

  def initialize(options)
    @gateway_response = {}
    @params = options
  end

  def make_purchase
    credit_card = get_card_object

    # Check if card is valid
    if credit_card.valid?
      options = { address: {}, billing_address: get_billing_address }

      # Make the purchase through ActiveMerchant
      charge_amount = (params[:order_total].to_f * 100).to_i
      response = gateway.purchase(charge_amount, credit_card, options)

      gateway_response.store(:error, "We couldn't process your credit card") if !response.success?
    else
      gateway_response.store(:error, "Your credit card seems to be invalid")
      gateway_response.store(:flash_error, "There was a problem processing your order. Please try again.")
    end

    gateway_response
  end

  # Get credit card object from ActiveMerchant
  def get_card_object
    ActiveMerchant::Billing::CreditCard.new(
      number: params[:card_info][:card_number],
      month: params[:card_info][:card_expiration_month],
      year: params[:card_info][:card_expiration_year],
      verification_value: params[:card_info][:cvv],
      first_name: params[:card_info][:card_first_name],
      last_name: params[:card_info][:card_last_name],
      type: get_card_type
    )
  end

  # Get the card type
  def get_card_type
    card_type = ''
    length = params[:card_info][:card_number].size

    if length == 15 && number =~ /^(34|37)/
      card_type = "AMEX"
    elsif length == 16 && number =~ /^6011/
      card_type = "Discover"
    elsif length == 16 && number =~ /^5[1-5]/
      card_type = "MasterCard"
    elsif (length == 13 || length == 16) && number =~ /^4/
      card_type = "Visa"
    else
      card_type = "Unknown"
    end

    card_type
  end

  def get_billing_address
    { name: "#{params[:billing_first_name]} #{params[:billing_last_name]}",
      address1: params[:billing_address_line_1],
      city: params[:billing_city], state: params[:billing_state],
      country: 'US',zip: params[:billing_zip],
      phone: params[:billing_phone] }
  end
end