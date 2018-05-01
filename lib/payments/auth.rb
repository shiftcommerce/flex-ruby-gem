module FlexCommerce
  module Payments
    # This service authorises the payment via the appropriate gateway
    # It acts simply as a router to the gateway defined by the "payment_gateway_reference" in the transaction
    class Auth
      attr_reader :order, :transaction
      # Creates the service ready for work

      # @param [PaymentTransaction] payment_transaction The order transaction to work with (defaults to the last one in the order)
      def initialize(payment_transaction: )
        self.transaction = payment_transaction
      end

      # Attempts to authorise the transaction
      # @raise Payments::Exception::NotAuthorised If the payment was not authorised for any reason
      delegate :call, to: :gateway_service

      private

      attr_writer :order, :transaction

      def payment_provider
        @payment_provider ||= PaymentProvider.find_by(reference: transaction.payment_gateway_reference)
      end

      def gateway_service
        @gateway_service ||= "Payments::#{payment_provider.service.camelize}::Auth".constantize.new(payment_provider: payment_provider, payment_transaction: transaction)
      end
    end
  end
end
