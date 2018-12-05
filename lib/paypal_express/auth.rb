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
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorized.new("Payment not authorised - #{response.message}", response: response)
          end
          return mark_transaction_with_errors!(response)
        end

        # Authorizing transaction
        auth_response = do_authorization(response)
        unless auth_response.success?
          unless is_user_error?(auth_response)
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorized.new("Failed authorising transaction - #{auth_response.message}", response: auth_response)
          end
          return mark_transaction_with_errors!(auth_response)
        end

        payment_transaction.attributes = { gateway_response: { payer_id: payer_id, token: token, transaction_id: response.params["transaction_id"], authorization_id: auth_response.params["transaction_id"]} }
        payment_transaction.save if payment_transaction.persisted?
        payment_transaction
      rescue ::ActiveMerchant::ConnectionError => ex
        raise ::FlexCommerce::PaypalExpress::Exception::ConnectionError.new("Failed authorising transaction due to a connection error.  Original message was #{ex.message}")
      end

      def do_express_checkout_payment
        Retry.call(rescue_errors: ::ActiveMerchant::ConnectionError) {
          ::NewRelic::Agent.increment_metric('Custom/Paypal/Do_Express_Checkout_Payment') if defined?(NewRelic::Agent)
          gateway.order(convert_amount(cart.total), token: token, payer_id: payer_id, currency: DEFAULT_CURRENCY)
        }
      end


      def do_authorization(response)
        Retry.call(rescue_errors: ::ActiveMerchant::ConnectionError) {
          ::NewRelic::Agent.increment_metric('Custom/Paypal/Do_Auhtorization') if defined?(NewRelic::Agent)
          gateway.authorize_transaction(response.params["transaction_id"], convert_amount(cart.total), transaction_entity: "Order", currency: DEFAULT_CURRENCY, payer_id: payer_id)
        }
      end
    end
  end
end
