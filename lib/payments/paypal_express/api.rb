require "active_support/concern"
# @module FlexCommerce::Payments::PaypalExpress::Api
module FlexCommerce
  module Payments
    module PaypalExpress
      # A concern for use in paypal express services that need access to the API
      module Api
        extend ActiveSupport::Concern

        PAYPAL_LOGIN = ENV.fetch('PAYPAL_LOGIN')
        PAYPAL_PASSWORD = ENV.fetch('PAYPAL_PASSWORD')
        PAYPAL_SIGNATURE = ENV.fetch('PAYPAL_SIGNATURE')
        ORDER_TEST_MODE = ENV.fetch('ORDER_TEST_MODE', "true")

        private

        def convert_amount(amount)
          (amount * 100.0).round.to_i
        end

        def gateway
          raise "Please ensure all Paypal Credentails are set in your env file." unless PAYPAL_LOGIN.present? && PAYPAL_PASSWORD.present? && PAYPAL_SIGNATURE.present?

          @gateway ||= gateway_class.new(test: test_mode, login: PAYPAL_LOGIN, password: PAYPAL_PASSWORD, signature: PAYPAL_SIGNATURE)
        end

        def test_mode
          puts "****************"
          puts ORDER_TEST_MODE.inspect
          ORDER_TEST_MODE == 'true'
        end
      end
    end
  end
end