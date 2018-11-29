# frozen_string_literal: true
require_relative 'api'

# @module FlexCommerce::PaypalExpress
module FlexCommerce
  module PaypalExpress
    # @class Setup
    #  
    # This service authorises the payment via the Paypal gateway
    class Auth
      
      DEFAULT_CURRENCY = "GBP".freeze

      # @initialize
      #
      # @param {String} token - Paypal token
      # @param {String} payer_id - Paypal user id
      def initialize(total: ,token: , payer_id:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway,)
        self.total = total
        self.token = token
        self.payer_id = payer_id
      end

      def call
        process_with_gateway
      end
  
      # Attempts to authorise the transaction
      # @raise Payments::Exception::NotAuthorised If the payment was not authorised for any reason
      delegate :call, to: :gateway_service
  
      private
  
      attr_reader :total, :token, :payer_id

      def process_with_gateway
        # Fetch Order details from Paypal
        response = gateway.order(convert_amount(total), token: token, payer_id: payer_id, currenct: DEFAULT_CURRENCY)
        unless paypal_response.success?
          unless is_user_error?(response)
            # TODO: Integrate new relic here
            # TODO: Integrate with I18n here
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorized.new("Payment not authorised - #{response.message}", response: response)
          end
          mark_transaction_with_errors!(response)
          return false
        end

        # Authorizing transaction
        auth_response = gateway.authorize_transaction(response.params["transaction_id"], convert_amount(total), transaction_entity: "Order", currency: DEFAULT_CURRENCY, payer_id: payer_id)
        unless auth_response.success?
          unless is_user_error?(auth_response)
            # TODO Integrate with new relic here
            # TODO Integrate with I18n here
            raise ::FlexCommerce::PaypalExpress::Exception::NotAuthorised.new("Failed authorising transaction - #{auth_response.message}", response: auth_response)
          end
          mark_transaction_with_errors!(response)
          return false
        end

        { transaction_id: response.params["transaction_id"], authorization_id: auth_response.params["transaction_id"]}, status: "success", tender_type: "paypal_express" }
      
      # TODO: There should be a time limit on this
      # TODO: And a retry process around this.
      rescue ::ActiveMerchant::ConnectionError => ex
        # TODO: I18n integration for the message
        raise ::Payments::Exception::ConnectionError.new("Failed authorising transaction due to a connection error.  Original message was #{ex.message}")
      end

      # Cleanup Later

      def payment_provider
        @payment_provider ||= PaymentProvider.find_by(reference: transaction.payment_gateway_reference)
      end
  
      def gateway_service
        @gateway_service ||= "Payments::#{payment_provider.service.camelize}::Auth".constantize.new(payment_provider: payment_provider, payment_transaction: transaction)
      end
    end
  end
end
