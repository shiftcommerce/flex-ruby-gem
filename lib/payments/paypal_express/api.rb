require "active_support/concern"
# @module FlexCommerce::Payments::PaypalExpress::Api
module FlexCommerce
  module Payments
    module PaypalExpress
      # A concern for use in paypal express services that need access to the API
      module Api
        extend ActiveSupport::Concern

        private

        def convert_amount(amount)
          (amount * 100.0).round.to_i
        end

        def gateway
          raise "Please ensure all Paypal Credentails are set in your env file." unless paypal_login.present? && paypal_password.present? && paypal_signature.present?

          @gateway ||= gateway_class.new(
            test: test_mode,
            login: paypal_login,
            password: paypal_password,
            signature: paypal_signature)
        end

        def test_mode
          FlexCommerceApi.config.order_test_mode == true
        end

        def paypal_login
          FlexCommerceApi.config.paypal_login
        end

        def paypal_password
          FlexCommerceApi.config.paypal_password
        end

        def paypal_signature
          FlexCommerceApi.config.paypal_signature
        end
      end
    end
  end
end