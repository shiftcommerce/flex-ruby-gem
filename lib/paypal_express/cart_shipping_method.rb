require 'bigdecimal'

# @module FlexCommerce::PaypalExpress
module FlexCommerce
  module PaypalExpress
    # @class CartShippingMethod
    # 
    # Used to decorate shipping methods based on Promotions
    class CartShippingMethod < SimpleDelegator

      ZERO = BigDecimal(0)

      def initialize(shipping_method, free)
        super(shipping_method)
        self.free = free
      end

      def is_free?
        free
      end

      def total
        return ZERO if is_free?
        super
      end

      def tax
        return ZERO if is_free?
        super
      end

      private

      attr_accessor :free

    end
  end
end
