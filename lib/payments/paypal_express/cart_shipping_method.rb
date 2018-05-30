require 'bigdecimal'

module FlexCommerce
  module Payments
    module PaypalExpress
      class CartShippingMethod < SimpleDelegator

        ZERO = BigDecimal.new(0)

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
end
