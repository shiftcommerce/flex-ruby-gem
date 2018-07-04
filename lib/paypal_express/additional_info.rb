require_relative 'api'

# @module FlexCommerce::PaypalExpress
module FlexCommerce
  module PaypalExpress
    # @class AdditionalInfo
    # Address verification service using paypal
    class AdditionalInfo
      include ::FlexCommerce::PaypalExpress::Api

      def initialize(gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, shipping_method_model: FlexCommerce::ShippingMethod, options:)
        self.gateway_class = gateway_class
        self.token = options[:token]
        self.shipping_method_model = shipping_method_model
        self.gateway_details = {}
      end

      # @method call
      # 
      # calculates the meta attributes for shipping method id, 
      # billing and shipping address
      # 
      # @return [PaymentAdditionalInfo]
      def call
        PaymentAdditionalInfo.new(meta: meta_data, id: SecureRandom.uuid)  
      end
      
      private
      
      attr_accessor :gateway_class, :token, :gateway_details, :shipping_method_model

      def meta_data
        details = gateway_details_for(token)

        {
          shipping_method_id: details[:shipping_method_id],
          email: details[:email],
          billing_address_attributes: details[:billing_address_attributes],
          shipping_address_attributes: details[:shipping_address_attributes]
        }
      end

      def gateway_details_for(token)
        response = gateway_details[token] ||= gateway.details_for(token)
        raise ::FlexCommerce::PaypalExpress::Exception::AccessDenied.new(response.message) unless response.success?
        Process::ParseResponse.new(response: response, shipping_method_model: shipping_method_model).parse
      end
    end

    class PaymentAdditionalInfo < OpenStruct; end
  end
end
