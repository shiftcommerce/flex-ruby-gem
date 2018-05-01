require "active_support/concern"
module FlexCommerce
  module Payments
    module PaypalExpress
      # A concern for use in paypal express services that need access to the API
      # See https://developer.paypal.com/docs/classic/api/errors/ for error code details
      module Api
        extend ActiveSupport::Concern
        USER_ERRORS = {
            "10410" => [:gateway_response, "Invalid token"],
            "10411" => [:gateway_response, "Checkout session expired"],
            "10415" => [:gateway_response, "Duplicate transaction"],
            "13113" => [:gateway_response, "Paypal declined the transaction"],
            "10417" => [:gateway_response, "Paypal cannot process this transaction.  Please use alternative payment method"],
            "10419" => [:gateway_response, "PayerID Missing"],
            "10421" => [:gateway_response, "Invalid token"],
            "10422" => [:gateway_response, "Invalid funding source. Please try again with a different funding source"],
            "10424" => [:gateway_response, "Invalid shipping address"],
            "10474" => [:gateway_response, "Invalid shipping country - must be the same as the paypal account"],
            "10486" => [:gateway_response, "Invalid funding source. Please try again with a different funding source"],
            "10736" => [:gateway_response, "Invalid shipping address"],
            "11084" => [:gateway_response, "No funding sources.  Please try a different payment method"],
            "13122" => [:gateway_response, "This transaction cannot be completed because it violates the PayPal User Agreement"],
            "10606" => [:gateway_response, "Paypal cannot process this transaction using the payment method provided"],
            "10626" => [:gateway_response, "Paypal declined this transaction due to its risk model"]
          }.freeze


        private

        def convert_amount(amount)
          (amount * 100.0).round.to_i
        end

        #TODO: here test mode, has to be integrated with test_mode value from setup class
        def gateway
          puts "in the gateway......."
          puts payment_provider.inspect
          @gateway ||= gateway_class.new(test: payment_provider.test_mode, login: payment_provider.meta_attributes["login"]["value"], password: payment_provider.meta_attributes["password"]["value"], signature: payment_provider.meta_attributes["signature"]["value"])
        end

        def is_user_error?(response)
          (USER_ERRORS.keys & response_error_codes(response)).present?
        end

        def mark_transaction_with_errors!(response)
          response_error_codes(response).each do |error_code|
            payment_transaction.errors.add(*USER_ERRORS[error_code])
          end
        end

        def response_error_codes(response)
          response.params["error_codes"].split(",")
        end

      end
    end
  end
end
