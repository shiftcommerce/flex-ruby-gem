require 'paypal_express/api'

# @module FlexCommerce::PaypalExpress::Process
module FlexCommerce
  module Payments
    module PaypalExpress
      # Address verification service using paypal
      #
      # A confirmed address means that the buyer's credit card billing and shipping address are the same.
      # In general, Paypal cannot confirm most addresses outside the U.S. at this time.
      # 
      # If your seller requires a confirmed shipping address, Paypal suggest the buyer to contact them directly. 
      # Sellers may deliver to an unconfirmed address, but they are responsible for any buyer-initiated disputes.

      class AddressVerification
        include ::FlexCommerce::PaypalExpress::Api
      
        # @param [PaymentAddressVerification] address_verification The address verification data to use
        def initialize(cart:, payment_provider:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway)
          self.cart = cart
          self.gateway_class = gateway_class
          self.payment_provider = payment_provider
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
          response = gateway.verify_address(email: cart.email, address: {address1: cart.shipping_address.address_line_1, zip: cart.shipping_address.postcode})
          {
            gateway_response: parse_gateway_response(response)
            errors: parse_errors(response)
          }
        end

        private

        attr_accessor :cart, :gateway_class, :payment_provider

        def parse_gateway_response(response)
          { 
            address_verification_confirmation_code: response.params["AddressVerifyResponse"]["ConfirmationCode"], 
            address_verification_ack: response.params["AddressVerifyResponse"]["Ack"]
          }
        end

        def parse_errors(response)
          errors = {}
          case response.params["AddressVerifyResponse"]["ConfirmationCode"]
            when "None"
              errors.email = I18n.t("payment_address_verifications.email_not_present") 
            when "Unconfirmed"
              errors.address = I18n.t("payment_address_verifications.unconfirmed")
          end
          errors.transaction = I18n.t("payment_address_verifications.service_failed") unless response.params["AddressVerifyResponse"]["Ack"]
          errors
        end
      end
    end
  end
end
