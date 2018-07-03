require_relative 'api'

# @module FlexCommerce::Payments::PaypalExpress
module FlexCommerce
  module Payments
    module PaypalExpress
      # @class Setup
      # 
      # This is the main class, which talks to ActiveMerchant gem to initiate a transaction using Paypal
      class Setup
        include ::FlexCommerce::Payments::PaypalExpress::Api
        

        # @initialize
        # 
        # @param {FlexCommerce::PaymentProviderSetup} payment_provider_setup
        # @param {FlexCommerce::Cart} cart
        # @param {Paypal Gateway} [gateway_class = ::ActiveMerchant::Billing::PaypalExpressGateway]
        # @param {URL} success_url - Generally Paypal confirmation page
        # @param {URL} cancel_url - Generally new transaction page
        # @param {IP} ip_address - User ip address
        # @param {boolean} [allow_shipping_change = true] - true: display shipping options, false: dont display shipping options
        # @param {URL} callback_url - Generally cart show page
        # @param {FlexCommerce::ShippingMethod} shipping_method_model = FlexCommerce::ShippingMethod
        # @param {boolean} [use_mobile_payments = false]
        # 
        # @note:
        # For `::ActiveMerchant::Billing::PaypalExpressGateway` to work
        # rails-site should include active merchant gem. Ideally this gem should be included in the gemspec.
        # But as we are using custom gem, which is not published to ruby gems, there is no way of including it within this gem dependency
        def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, success_url:, cancel_url:, ip_address:, allow_shipping_change: true, callback_url:, shipping_method_model: FlexCommerce::ShippingMethod, use_mobile_payments: false, description: nil)
          self.gateway_class = gateway_class
          self.cart = cart
          self.allow_shipping_change = allow_shipping_change
          self.success_url = success_url
          self.cancel_url = cancel_url
          self.ip_address = ip_address
          self.callback_url = callback_url
          self.shipping_method_model = shipping_method_model
          self.use_mobile_payments = use_mobile_payments
          self.description = description
        end

        def call
          return false unless valid_shipping_method?
          

          response = gateway.setup_order(convert_amount(cart.total), paypal_params)
          # If paypal setup went fine, redirect to the paypal page
          if response.success?
            PaypalSetup.new(setup_type:  "redirect", redirect_url: gateway.redirect_url_for(response.token, mobile: use_mobile_payments))
          else
            # @TODO Find out where to get the message from and add it
            error = "An error occured communicating with paypal #{response.message} \n\n#{response.params.to_json}. Total sent was #{convert_amount(cart.total)} Parameters sent were \n\n#{paypal_params}"
            raise ::FlexCommerce::Payments::Exception::AccessDenied.new(error)
          end
        rescue ::FlexCommerce::Payments::Exception::AccessDenied => exception
          PaypalSetup.new(errors: exception)
        end

        private

        attr_accessor :description, :cart, :gateway_class, :success_url, :cancel_url, :ip_address, :allow_shipping_change, :callback_url, :shipping_method_model, :use_mobile_payments

        def paypal_params
          PaypalParams.new(
            cart: cart,
            success_url: success_url,
            cancel_url: cancel_url,
            ip_address: ip_address,
            allow_shipping_change: allow_shipping_change,
            callback_url: callback_url,
            shipping_method_model: shipping_method_model,
            use_mobile_payments: use_mobile_payments,
            description: description
          ).call
        end

        # @method shipping_methods
        # 
        # @returns shipping methods with promotions applied
        def shipping_methods
          @shipping_methods ||= ShippingMethodsForCart.new(cart: cart, shipping_methods: shipping_method_model.all).call.sort_by(&:total)
        end

        def valid_shipping_method?
          return true if cart.shipping_method_id.nil? || shipping_methods.any? {|sm| sm.id == cart.shipping_method_id}
          raise ::FlexCommerce::Payments::Exception::AccessDenied.new(I18n.t("payment_setup.shipping_method_not_available"))
        end
      end

      class PaypalSetup < OpenStruct; end
    end
  end
end
