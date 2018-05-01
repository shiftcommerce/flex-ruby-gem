# frozen_string_literal: true
module FlexCommerce
  module Payments
    module PaymentProcess
      module Middleware
        #
        # Create Order middleware for use with the payment processor.  See {Payments::PaymentProcessor}
        #
        class Auth
          # @param [PaymentProcess] payment_process The payment_process used to contain the whole process
          # @param [OpenStruct] state Used internally to track the state throughought the process without going to the DB
          def initialize(payment_process:, state:)
            self.payment_process = payment_process
            self.state = state
          end

          # Authorise the payment process by creating a transaction and storing it in
          # state.transaction
          def call
            state.transaction = find_or_create_transaction_for_cart
            state.message = :authorised
            state.status = :authorised
          end

          private

          attr_accessor :payment_process, :state

          def within_transaction(&block)
            ActiveRecord::Base.transaction(&block)
          end

          def find_or_create_transaction_for_cart
            if payment_process.internal_state["transaction_id"]
              PaymentTransaction.find(payment_process.internal_state["transaction_id"])
            else
              create_transaction_for_cart
            end
          end

          def create_transaction_for_cart
            within_transaction do
              transaction = PaymentTransaction.create container_id: payment_process.cart_id,
                                                      payment_gateway_reference: payment_process.payment_gateway_reference,
                                                      transaction_type: PaymentTransaction::TRANSACTION_TYPE_AUTHORISATION,
                                                      status: PaymentTransaction::STATUS_RECEIVED,
                                                      amount: payment_process.cart.total,
                                                      currency: "GBP",
                                                      gateway_response: payment_process.payment_gateway_response
              handle_transaction_errors(transaction) unless transaction.errors.empty?
              payment_process.internal_state["transaction_id"] = transaction.id
              payment_process.save!
              transaction
            end
          end

          def handle_transaction_errors(transaction)
            raise_if_invalid_transaction(transaction)
            if transaction.errors[:gateway_response].present?
              transaction.errors[:gateway_response].each do |error|
                add_validation_error(:gateway_response, error)
              end
            end
            state.status = ::Payments::PaymentProcessor::STATUS_INVALID
            payment_process.status = state.status
            payment_process.save!
            throw(:abort, false)
          end

          def add_validation_error(key, message)
            payment_process.validation_errors[key] ||= []
            payment_process.validation_errors[key] << message
          end

          def add_processing_error(key, message)
            payment_process.processing_errors[key] ||= []
            payment_process.processing_errors[key] << message
          end

          def raise_if_invalid_transaction(transaction)
            if transaction.errors.messages.except(:gateway_response).present?
              raise ::Payments::Exception::NotAuthorised.new I18n.t("payment_auth.transaction_validation_errors",
                                                                    message: transaction.errors.messages.to_json)
            end
          end
        end
      end
    end
  end
end
