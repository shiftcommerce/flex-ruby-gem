require_relative 'api'

# @module FlexCommerce::PaypalExpress
module FlexCommerce
  module PaypalExpress
    # @class GenerateSummary
    #
    # This class is used while setting up the paypal for FE
    # It deals with line items total, sub total, tax calculations and
    # Also deals with discounted line items and discounts inorder to send to paypal
    #
    class GenerateSummary
      include ::FlexCommerce::PaypalExpress::Api

      def initialize(cart: , use_tax: false, gift_card_amount:)
        self.cart = cart
        self.use_tax = use_tax
        self.gift_card_amount = gift_card_amount
        raise "use_tax is not yet supported.  FlexCommerce::PaypalExpress::GenerateSummary should support it in the future" if use_tax
      end

      # @method call
      #
      # @returns an object with subtotal, tax, handling, shipping and items keys
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

      # @method subtotal
      #
      # @returns the sum of line items total. This doesnt include any promotions
      def subtotal
        items.sum {|i| i[:quantity] * (i[:amount])}
      end

      # @method total
      #
      # @return amount after converting cart total from pence to pounds
      def total
        convert_amount(cart.total)
      end

      # @method tax
      #
      # @returns the sum of total line items tax
      def tax
        items.sum {|i| i[:tax] * i[:quantity]}
      end

      # @method handling
      #
      # @returns Payment handling charges, which is 0
      def handling
        0
      end

      # @method shipping
      #
      # @returns 0 if cart is eligible for free shipping
      # @returns cart.shipping_total, if cart is not eligibl for free shipping
      def shipping
        return 0 if cart.free_shipping
        convert_amount(cart.shipping_total)
      end

      # @mthod items
      #
      # @returns both line items and discounts
      def items
        normal_items + discount_items + gift_cards
      end

      # @method discounts
      #
      # @returns [] if there are no discounts on cart
      # @returns Array containing about the total discount amount, if any applied.
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

      # @method gift_cards
      #
      # @returns [] if there are no gift cards on cart
      # @returns Array containing total gift card amount, if any applied.
      def gift_cards
        return [] if gift_card_amount.nil? || gift_card_amount.zero?
        [
            {
                name: "Gift card",
                number: "NA",
                quantity: 1,
                amount: convert_amount(BigDecimal(0) - gift_card_amount),
                description: "Gift card",
                tax: 0
            }
        ]
      end

      # @method normal_items
      #
      # @returns Object, the normal line items added to cart
      # @note these line items unit prices will be without any discounts
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

      attr_accessor :cart, :use_tax, :gift_card_amount
    end
  end
end
