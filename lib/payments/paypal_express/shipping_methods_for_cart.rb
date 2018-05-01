module FlexCommerce
  module Payments
    module PaypalExpress
      class ShippingMethodsForCart

        include Enumerable

        def initialize(cart:, shipping_methods:)
          self.cart = cart
          self.shipping_methods = shipping_methods
          self.shipping_promotions = cart.available_shipping_promotions
        end

        def each
          free_shipping_method_ids = [ ]
          shipping_promotions.each do |promotion|
            if can_apply_promotion_to_cart?(promotion: promotion)
              free_shipping_method_ids << promotion.shipping_method_ids
            end
          end

          free_shipping_method_ids.flatten!

          shipping_methods.each do |shipping_method|
            shipping_method_free = free_shipping_method_ids.include?(shipping_method.id)

            yield CartShippingMethod.new(shipping_method, shipping_method_free)
          end
          nil
        end

        private

        attr_accessor :cart, :shipping_methods, :shipping_promotions

        def can_apply_promotion_to_cart?(promotion:)
          (cart.sub_total - cart.total_discount) >= promotion.minimum_cart_total&.to_i
        end

      end
    end
  end
end
