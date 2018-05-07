require_relative 'api'

module FlexCommerce
  module Payments
    module PaypalExpress
      class GenerateSummary
        include ::FlexCommerce::Payments::PaypalExpress::Api
        def initialize(cart: , use_tax: false)
          self.cart = cart
          self.use_tax = use_tax
          raise "use_tax is not yet supported.  Payments::PaypalExpress::GenerateSummary should support it in the future" if use_tax
        end

        def call
          {
              subtotal: subtotal,
              tax: tax,
              handling: handling,
              shipping: shipping,
              items: items
          }
        end

        private

        def subtotal
          items.sum {|i| i[:quantity] * (i[:amount])}
        end

        def total
          convert_amount(cart.total)
        end

        def tax
          items.sum {|i| i[:tax] * i[:quantity]}
        end

        def handling
          0
        end

        def shipping
          convert_amount(cart.shipping_total)
        end

        def items
          normal_items + discount_items
        end

        def discount_items
          return [] if cart.total_discount == 0
          [
              {
                  name: "Total discounts",
                  number: "NA",
                  quantity: 1,
                  amount: convert_amount(BigDecimal(0) - cart.total_discount),
                  description: "Total discounts",
                  tax: 0
              }
          ]
        end

        def normal_items
          @normal_items ||= cart.line_items.map do |li|
            {
                name: li.title,
                number: li.item.sku,
                quantity: li.unit_quantity,
                amount: convert_amount(li.unit_price),
                description: li.title,
                tax: 0
            }
          end
        end

        attr_accessor :cart, :use_tax
      end
    end
  end
end