require "active_support/concern"
# @module FlexCommerce::Payments::PaypalExpress::Api
module FlexCommerce
  module Payments
    module PaypalExpress
      # A concern for use in paypal express services that need access to the API
      module Api
        extend ActiveSupport::Concern

        PAYPAL_LOGIN = ENV['PAYPAL_LOGIN']
        PAYPAL_PASSWORD = ENV['PAYPAL_PASSWORD']
        PAYPAL_SIGNATURE = ENV['PAYPAL_SIGNATURE']

        private

        def convert_amount(amount)
          (amount * 100.0).round.to_i
        end

        def gateway
          validate_keys
          @gateway ||= gateway_class.new(test: payment_provider.test_mode, login: PAYPAL_LOGIN, password: PAYPAL_PASSWORD, signature: PAYPAL_SIGNATURE)
        end

        def validate_keys
          raise "Please ensure all Paypal Credentails are set in your env file." unless PAYPAL_LOGIN.present? && PAYPAL_PASSWORD.present? && PAYPAL_SIGNATURE.present?
        end

      end
    end
  end
end
