module FlexCommerce
  module Payments
    # This service returns additional info using the appropriate gateway.  This will always be gateway specific
    # so please refer to the docs for the gateway that you are using for details of what it can provide
    # It acts simply as a router to the gateway defined by the "payment_gateway_reference"
    class AdditionalInfo

      def initialize(payment_provider_id:, options: {})
        self.payment_provider_id = payment_provider_id
        self.options = options
      end

      # Performs the additional info request using the delegated service
      # see the docs for the service being used for more details
      def call
        delegated_service.call
      end

      private

      attr_accessor :payment_provider_id, :options

      def delegated_service
        @delegated_service ||= delegated_service_class.new(payment_provider: payment_provider, options: options)
      end

      def delegated_service_class
        "::Payments::#{payment_provider_id.camelize}::AdditionalInfo".constantize
      end

      def payment_provider
        FlexCommerce::PaymentProvider.all.select{ |p| p.reference == payment_provider_id }.first
      end
    end
  end
end
