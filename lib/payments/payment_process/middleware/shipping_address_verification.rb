# frozen_string_literal: true
module FlexCommerce
  module Payments
    module PaymentProcess
      module Middleware
        #
        # Address Verification middleware for use with the payment processor.  See {Payments::PaymentProcessor}
        #
        class Payments::PaymentProcess::Middleware::ShippingAddressVerification
          ADDRESS_ATTRIBUTES = %w(address_line_1 address_line_2 address_line_3 city
                                  state postcode country first_name middle_names last_name).freeze

          # @param [PaymentProcess] payment_process The payment_process used to contain the whole process
          # @param [OpenStruct] state Used internally to track the state throughought the process without going to the DB
          #  state must be populated with "container" for this to work
          def initialize(payment_process:, state:)
            self.payment_process = payment_process
            self.state = state
          end

          # Perform the address verification for the payment process
          def call
            email = state.transaction.container.email
            address_verification = PaymentAddressVerification.new(transaction_id: state.transaction.id,
                                                                  address_attributes: address_attributes,
                                                                  email: email)
            ::Payments::AddressVerification.new(address_verification: address_verification).call
            state.message = :shipping_address_verification
            state.status = :shipping_address_verification
          end

          private

          attr_accessor :payment_process, :state

          def address_attributes
            state.transaction.container.shipping_address.attributes.slice(*ADDRESS_ATTRIBUTES)
          end
        end
      end
    end
  end
end
