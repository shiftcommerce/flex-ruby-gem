module FlexCommerce
  module Payments
    # This service validates the address verification data using the appropriate gateway
    # It acts simply as a router to the gateway defined by the "payment_gateway_reference" in the transaction referenced in the transaction_id of the verification data
    class AddressVerification

      # @param [PaymentAddressVerification] address_verification The address verification data to use
      def initialize(address_verification:)
        self.address_verification = address_verification
      end

      # Performs the address verification using the delegated service
      # see the docs for the service being used for more details - a core requirement
      # is to ensure that address_verification.valid? returns false if the address verification failed
      def call
        verification_service.call
      end

      private

      attr_accessor :address_verification

      def verification_service
        @verification_service ||= verification_service_class.new(payment_provider: payment_provider, address_verification: address_verification)
      end

      def payment_provider
        @payment_provider ||= PaymentProvider.all.select{ |p| p.reference == transaction.payment_gateway_reference}.first
      end

      def verification_service_class
        "::Payments::#{payment_provider.reference.camelize}::AddressVerification".constantize
      end

      def transaction
        address_verification.transaction || raise("transaction #{address_verification.transaction_id} not found")
      end
    end
  end
end
