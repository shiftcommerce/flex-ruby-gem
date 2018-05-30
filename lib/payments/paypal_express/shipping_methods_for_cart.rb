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

        def call
          free_shipping_method_ids = [ ]
          shipping_promotions.reverse.each do |promotion|
            # See if promotion is having a shipping method, 
            # and also see if that cart total is eligible for promotion
            if promotion.shipping_methods && can_apply_promotion_to_cart?(promotion: promotion)
              free_shipping_method_ids << promotion.shipping_methods.map(&:id)
            end
          end

          free_shipping_method_ids.flatten!
          updated_shipping_methods = []
          shipping_methods.each do |shipping_method|
            shipping_method_free = free_shipping_method_ids.include?(shipping_method.id)

            updated_shipping_methods << CartShippingMethod.new(shipping_method, shipping_method_free)
          end
          updated_shipping_methods
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
