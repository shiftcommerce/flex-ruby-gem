# frozen_string_literal: true
require_relative 'api'
require 'retry'

# @module FlexCommerce::PaypalExpress
module FlexCommerce
  module PaypalExpress
    # @class Setup
    #  
    # This service authorises the payment via the Paypal gateway
    class Auth
      include ::Retry
      include ::FlexCommerce::PaypalExpress::Api
      
      DEFAULT_CURRENCY = "GBP"
      MAX_NO_OF_RETRIES = 2

      # @initialize
      #
      # @param {String} token - Paypal token
      # @param {String} payer_id - Paypal user id
      def initialize(cart:, token:, payer_id:, payment_transaction:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway)
        self.cart = cart
        self.token = token
        self.payer_id = payer_id
        self.payment_transaction = payment_transaction
        self.gateway_class = gateway_class
      end

      def call
        process_with_gateway
      end
 
      private
  
      attr_accessor :cart, :token, :payer_id, :payment_transaction, :gateway_class

      def process_with_gateway
        # Fetch Order details from Paypal
        response = do_express_checkout_payment
        unless response.success?
          unless is_user_error?(response)
            # TODO: Integrate new relic here
            # TODO: Integrate with I18n here
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorized.new("Payment not authorised - #{response.message}", response: response)
          end
          return mark_transaction_with_errors!(response)
        end

        # Authorizing transaction
        auth_response = do_authorization(response)
        unless auth_response.success?
          unless is_user_error?(auth_response)
            # TODO Integrate with new relic here
            # TODO Integrate with I18n here
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorized.new("Failed authorising transaction - #{auth_response.message}", response: auth_response)
          end
          return mark_transaction_with_errors!(auth_response)
        end

        payment_transaction.attributes = { gateway_response: { payer_id: payer_id, token: token, transaction_id: response.params["transaction_id"], authorization_id: auth_response.params["transaction_id"]} }
        payment_transaction.save if payment_transaction.persisted?
        payment_transaction
      # TODO: There should be a time limit on this
      # TODO: And a retry process around this.
      rescue ::ActiveMerchant::ConnectionError => ex
        # TODO: I18n integration for the message
        raise ::FlexCommerce::PaypalExpress::Exception::ConnectionError.new("Failed authorising transaction due to a connection error.  Original message was #{ex.message}")
      end

      def do_express_checkout_payment
        Retry.call(no_of_retries: 5, rescue_errors: ::ActiveMerchant::ConnectionError) {
          gateway.order(convert_amount(cart.total), token: token, payer_id: payer_id, currency: DEFAULT_CURRENCY)
        }
      end


      def do_authorization(response)
        Retry.call(no_of_retries: 5, rescue_errors: ::ActiveMerchant::ConnectionError) {
          gateway.authorize_transaction(response.params["transaction_id"], convert_amount(cart.total), transaction_entity: "Order", currency: DEFAULT_CURRENCY, payer_id: payer_id)
        }
      end
    end
  end
end
