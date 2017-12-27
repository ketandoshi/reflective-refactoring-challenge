# All the shipping related functionality should happen from here only.
#
class Shipping
  def self.get_shipping_charge(shipping_method)
    shipping_fees = 0.0

    case shipping_method
      when 'ground'
        shipping_fees = 0.0
      when 'two-day'
        shipping_fees = 15.75
      when "overnight"
        shipping_fees = 25
    end

    shipping_fees
  end
end