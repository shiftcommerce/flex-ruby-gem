require_relative 'api'
module FlexCommerce
  module Payments
    module PaypalExpress
      # Paypal Express authorisation
      class Auth
        DEFAULT_CURRENCY = "GBP"
        # include ::Payments::PaypalExpress::Api
        # Creates the service ready for work

        # @param [PaymentTransaction] payment_transaction The order transaction to work with (defaults to the last one in the order)
        def initialize(payment_transaction:, payment_provider:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, shipping_method_model: ShippingMethod)
          self.payment_provider = payment_provider
          self.gateway_class = gateway_class
          self.shipping_method_model = shipping_method_model
          self.payment_transaction = payment_transaction
        end

        def call
          token = payment_transaction.gateway_response["token"]
          payer_id = payment_transaction.gateway_response["payer_id"]
          replace_with_duplicate(token: token, payer_id: payer_id) || process_with_gateway(token: token, payer_id: payer_id)
        end

        private

        attr_accessor :payment_provider, :gateway_class, :payment_transaction, :shipping_method_model

        def process_with_gateway(token:, payer_id:)
          response = gateway.order(convert_amount(payment_transaction.amount), token: token, payer_id: payer_id, currency: DEFAULT_CURRENCY)
          unless response.success?
            unless is_user_error?(response)
              ::NewRelic::Agent.increment_metric('Custom/Payments/NotAuthorised')
              raise ::Payments::Exception::NotAuthorised.new("Payment not authorised - #{response.message}", response: response)
            end
            mark_transaction_with_errors!(response)
            return false
          end
          auth_response = gateway.authorize_transaction(response.params["transaction_id"], convert_amount(payment_transaction.amount), transaction_entity: "Order", currency: DEFAULT_CURRENCY, payer_id: payer_id)
          unless auth_response.success?
            unless is_user_error?(auth_response)
              ::NewRelic::Agent.increment_metric('Custom/Payments/NotAuthorised')
              raise ::Payments::Exception::NotAuthorised.new("Failed authorising transaction - #{auth_response.message}", response: auth_response)
            end
            mark_transaction_with_errors!(auth_response)
            return false
          end
          payment_transaction.attributes = { gateway_response: { payer_id: payer_id, token: token, transaction_id: response.params["transaction_id"], authorization_id: auth_response.params["transaction_id"]}, status: "success", tender_type: "paypal_express"  }
          payment_transaction.save if payment_transaction.persisted?
        rescue ::ActiveMerchant::ConnectionError => ex
          raise ::Payments::Exception::ConnectionError.new("Failed authorising transaction due to a connection error.  Original message was #{ex.message}")
        end

        def replace_with_duplicate(token:, payer_id:)
          duplicate = PaymentTransaction.latest_first\
            .succeeded.where(container_id: payment_transaction.container_id,
                            transaction_type: payment_transaction.transaction_type,
                            amount: payment_transaction.amount,
                            currency: payment_transaction.currency
                            ) \
            .where("gateway_response @> ?::jsonb", {token: token, payer_id: payer_id}.to_json).first
          return false unless duplicate
          payment_transaction.id = duplicate.id
          payment_transaction.reload
          true
        end
      end
    end
  end
end
