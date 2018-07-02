require "flex_commerce_api/api_base"

# @module FlexCommerce
module FlexCommerce
  #
  # @module PaymentProviderSetup
  # A flex commerce PaymentProvider model
  #
  # This model is used to define a payment gateway and provide instructions
  # to the front end application on how to set up the gateway in a browser 
  # (i.e. redirect to paypal etc..)
  #
  #
  module PaymentProviderSetup

    class << self; attr_accessor :setup_type, :redirect_url; end
    
    # @method call
    # 
    # Triggers call to PaypalExpress::Setup service class to setup paypal
    # 
    # @return [FlexCommerce::PaymentAdditionalInfo]
    def self.call(cart:, ip_address:, success_url:, cancel_url:, allow_shipping_change:, callback_url:, use_mobile_payments:)
      # Call PaypalExpress::Setup service class, which will talk to active merchant gem for setup process
      setup ||= ::FlexCommerce::Payments::PaypalExpress::Setup.new(cart: cart,
        payment_provider_setup: self,
        ip_address: ip_address,
        success_url: success_url,
        cancel_url: cancel_url,
        allow_shipping_change: allow_shipping_change,
        callback_url: callback_url,
        use_mobile_payments: use_mobile_payments).call
    end
  end
end
