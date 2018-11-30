require 'paypal_express/api'

# @module FlexCommerce::PaypalExpress::Process
module FlexCommerce
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
      def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway)
        self.cart = cart
        self.gateway_class = gateway_class
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
        parse_gateway_response(response).merge(parse_errors(response))
      end

      private

      attr_accessor :cart, :gateway_class

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
            errors[:email] = "Email not present in paypal" 
          when "Unconfirmed"
            errors[:address] = "Address is not confirmed"
        end
        errors[:transaction] = "Address verification service failed" unless response.params["AddressVerifyResponse"]["Ack"]
        errors
      end
    end
  end
end
