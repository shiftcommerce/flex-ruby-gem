module FlexCommerce
  module Payments
    class Setup
      def initialize(cart:, payment_provider_id:, success_url:, cancel_url:, ip_address:, allow_shipping_change: false, callback_url:, use_mobile_payments: false )
        self.payment_provider_id = payment_provider_id
        self.cart = cart
        self.success_url = success_url
        self.cancel_url = cancel_url
        self.ip_address = ip_address
        self.allow_shipping_change = allow_shipping_change
        self.callback_url = callback_url
        self.use_mobile_payments = use_mobile_payments
      end

      def call
        setup_service.call
      end

      def payment_provider
        FlexCommerce::PaymentProvider.all.select{ |p| p.reference == payment_provider_id }.first
      end

      private

      attr_accessor :payment_provider_id, :cart, :success_url, :cancel_url, :ip_address, :allow_shipping_change, :callback_url, :use_mobile_payments

      def setup_service
        @setup_service ||= setup_service_class.new(
          cart: cart,
          payment_provider_setup: payment_provider_setup,
          payment_provider: payment_provider,
          success_url: success_url,
          cancel_url: cancel_url,
          ip_address: ip_address,
          callback_url: callback_url,
          allow_shipping_change: allow_shipping_change,
          use_mobile_payments: use_mobile_payments)
      end

      def setup_service_class
        "::FlexCommerce::Payments::#{payment_provider_id.camelize}::Setup".constantize
      end

      def payment_provider_setup
        PaymentProviderSetup.new 
      end
    end
  end
end
