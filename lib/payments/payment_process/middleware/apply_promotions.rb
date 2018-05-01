# frozen_string_literal: true
module FlexCommerce
  module Payments
    module PaymentProcess
      module Middleware
        #
        # Create Order middleware for use with the payment processor.  See {Payments::PaymentProcessor}
        #
        class ApplyPromotions
          # @param [PaymentProcess] payment_process The payment_process used to contain the whole process
          # @param [OpenStruct] state Used internally to track the state throughought the process without going to the DB
          def initialize(payment_process:, state:, promotions_service: ::Promotions)
            self.payment_process = payment_process
            self.state = state
            self.promotions_service = promotions_service
          end

          # Apply promotions to the payment process's cart
          # state.transaction
          def call
            cart = payment_process.cart
            promotions_service.apply_to_cart(cart: cart) unless cart.nil?
            state.message = :promotions_applied
            state.status = :promotions_applied
          end

          private

          attr_accessor :payment_process, :state, :promotions_service
        end
      end
    end
  end
end
