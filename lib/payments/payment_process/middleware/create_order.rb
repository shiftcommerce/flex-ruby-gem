# frozen_string_literal: true
module FlexCommerce
  module Payments
    module PaymentProcess
      module Middleware
        #
        # Create Order middleware for use with the payment processor.   See {Payments::PaymentProcessor}
        #
        class CreateOrder
          # @param [PaymentProcess] payment_process The payment_process used to contain the whole process.
          # @param [OpenStruct] state Used internally to track the state throughought the process without going to the DB
          def initialize(payment_process:, state:)
            self.payment_process = payment_process
            self.state = state
          end

          #
          # Creates the order or returns the existing order if the payment_process record already has one
          #
          def call
            create_order unless payment_process.order.present?
            state.message = :order_created
            state.status = :order_created
            state.order = payment_process.order
          end

          private

          attr_accessor :payment_process, :state

          def create_order
            within_transaction do
              payment_process.order = payment_process.cart.becomes!(Order)
              Orders.process_order(cart: payment_process.order)
              payment_process.order.save!
              payment_process.internal_state[:order] = true
              payment_process.save!
            end
          end

          def within_transaction(&block)
            ActiveRecord::Base.transaction(&block)
          end
        end
      end
    end
  end
end
