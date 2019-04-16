require "active_support/concern"
# @module FlexCommerce::PaypalExpress::Api
module FlexCommerce
  module PaypalExpress
    # A concern for use in paypal express services that need access to the API
    module Api
      extend ActiveSupport::Concern

      USER_ERRORS = {
        "10410" => {gateway_response: "Invalid token"},
        "10411" => {gateway_response: "Checkout session expired"},
        "10415" => {gateway_response: "Duplicate transaction"},
        "13113" => {gateway_response: "Paypal declined the transaction"},
        "10417" => {gateway_response: "Paypal cannot process this transaction.  Please use alternative payment method"},
        "10419" => {gateway_response: "PayerID Missing"},
        "10421" => {gateway_response: "Invalid token"},
        "10422" => {gateway_response: "Invalid funding source. Please try again with a different funding source"},
        "10424" => {gateway_response: "Invalid shipping address"},
        "10474" => {gateway_response: "Invalid shipping country - must be the same as the paypal account"},
        "10486" => {gateway_response: "Invalid funding source. Please try again with a different funding source"},
        "10736" => {gateway_response: "Invalid shipping address"},
        "11084" => {gateway_response: "No funding sources.  Please try a different payment method"},
        "13122" => {gateway_response: "This transaction cannot be completed because it violates the PayPal User Agreement"},
        "10606" => {gateway_response: "Paypal cannot process this transaction using the payment method provided"},
        "10626" => {gateway_response: "Paypal declined this transaction due to its risk model"}
      }.freeze

      private

      def gateway
        verify_credentials
        @gateway ||= gateway_class.new(
          test: test_mode,
          login: paypal_login,
          password: paypal_password,
          signature: paypal_signature)
      end

      def is_user_error?(response)
        (USER_ERRORS.keys & response_error_codes(response)).present?
      end

      def mark_transaction_with_errors!(response)
        errors = []
        response_error_codes(response).each do |error_code|
          errors.push(USER_ERRORS[error_code])
        end
        errors
      end

      def response_error_codes(response)
        response.params["error_codes"].split(",")
      end

      def verify_credentials
        unless paypal_login.present? && paypal_password.present? && paypal_signature.present? then
          raise "Please ensure all Paypal Credentails are set in your env file."
        end
      end

      # DEFAULT value for test mode is true.
      def test_mode
        FlexCommerceApi.config.order_test_mode == true || FlexCommerceApi.config.order_test_mode == "true"
      end

      # PAYPAL CREDENTAILS

      def paypal_login
        FlexCommerceApi.config.paypal_login
      end

      def paypal_password
        FlexCommerceApi.config.paypal_password
      end

      def paypal_signature
        FlexCommerceApi.config.paypal_signature
      end

      def convert_amount(amount)
        (amount * 100.0).round.to_i
      end

    end
  end
end