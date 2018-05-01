require_relative 'api'
module FlexCommerce
  module Payments
    module PaypalExpress
      # Address verification service using paypal
      class AddressVerification
        # include ::Payments::PaypalExpress::Api
        # @param [PaymentAddressVerification] address_verification The address verification data to use
        def initialize(address_verification:, payment_provider:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway)
          self.address_verification = address_verification
          self.gateway_class = gateway_class
          self.payment_provider = payment_provider
          self.transaction = address_verification.transaction
        end

        # Performs the address validation
        #
        # The results are stored in the transaction's 'gateway_response' data - the following 2 keys will be added
        #  'address_verification_confirmation_code' ("Confirmed", "Unconfirmed" or "None")
        #  'address_verification_ack' ("Success" or "Failure")
        #
        # Also, if the confirmation code is not "Confirmed" or the ack value is not "Success" then the address_verification object
        # has errors marked on it.
        def call
          response = gateway.verify_address(email: address_verification.email, address: {address1: address_verification.address.address_line_1, zip: address_verification.address.postcode})
          update_transaction(response)
          mark_errors(response)
        end

        private

        attr_accessor :address_verification, :gateway_class, :payment_provider, :transaction

        def update_transaction(response)
          transaction.update_column :gateway_response, transaction.gateway_response.merge({"address_verification_confirmation_code" => response.params["AddressVerifyResponse"]["ConfirmationCode"], "address_verification_ack" => response.params["AddressVerifyResponse"]["Ack"]})
        end

        def mark_errors(response)
          case response.params["AddressVerifyResponse"]["ConfirmationCode"]
            when "None"
              address_verification.errors.add(:email, I18n.t("payment_address_verifications.email_not_present"))
            when "Unconfirmed"
              address_verification.errors.add(:address, I18n.t("payment_address_verifications.unconfirmed"))
          end
          address_verification.errors.add(:transaction, I18n.t("payment_address_verifications.service_failed")) unless response.params["AddressVerifyResponse"]["Ack"]
        end
      end
    end
  end
end
