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
        DEFAULT_DESCRIPTION = "Shift Commerce Order"

        # @initialize
        # 
        # @param {FlexCommerce::PaymentProviderSetup} payment_provider_setup
        # @param {FlexCommerce::Cart} cart
        # @param {FlexCommerce::PaymentProvider} payment_provider
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
        def initialize(payment_provider_setup: , cart:, payment_provider:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, success_url:, cancel_url:, ip_address:, allow_shipping_change: true, callback_url:, shipping_method_model: FlexCommerce::ShippingMethod, use_mobile_payments: false)
          self.payment_provider = payment_provider
          self.payment_provider_setup = payment_provider_setup
          self.gateway_class = gateway_class
          self.cart = cart
          self.allow_shipping_change = allow_shipping_change
          self.success_url = success_url
          self.cancel_url = cancel_url
          self.ip_address = ip_address
          self.callback_url = callback_url
          self.shipping_method_model = shipping_method_model
          self.use_mobile_payments = use_mobile_payments
        end

        def call
          return false unless valid_shipping_method?
          
          response = gateway.setup_order(convert_amount(cart.total), paypal_params)

          # If paypal setup went fine, redirect to the paypal page
          if response.success?
            payment_provider_setup.setup_type = "redirect"
            payment_provider_setup.redirect_url = gateway.redirect_url_for(response.token, mobile: use_mobile_payments)
            payment_provider_setup
          else
            raise "An error occured communicating with paypal #{response.message} \n\n#{response.params.to_json}. Total sent was #{convert_amount(cart.total)} Parameters sent were \n\n#{paypal_params}" # @TODO Find out where to get the message from and add it
          end
        end

        private

        attr_accessor :payment_provider, :payment_provider_setup, :cart, :gateway_class, :success_url, :cancel_url, :ip_address, :allow_shipping_change, :callback_url, :shipping_method_model, :use_mobile_payments

        def paypal_params
          base_paypal_params
            .merge(paypal_shipping_address_params)
            .merge(paypal_items)
            .merge(ui_callback_params)
            .merge(shipping_options_params)
        end

        def paypal_shipping_address_params
          return {} unless cart.shipping_address
          shipping_address = cart.shipping_address
          {
            address_override: true,
            shipping_address: {
              name: "#{shipping_address.first_name} #{shipping_address.middle_names} #{shipping_address.last_name}",
              address1: shipping_address.address_line_1,
              address2: "#{shipping_address.address_line_2} #{shipping_address.address_line_3}",
              city: shipping_address.city,
              state: shipping_address.state,
              country: shipping_address.country,
              zip: shipping_address.postcode

            }
          }
        end

        def base_paypal_params
          {
            currency: "GBP",
            description: DEFAULT_DESCRIPTION,
            ip: ip_address,
            return_url: success_url,
            cancel_return_url: cancel_url,
            subtotal: summary[:subtotal], # As the cart total wont include any shipping if it has no shipping method
            handling: summary[:handling],
            tax: 0,
            shipping: summary[:shipping]
          }
        end

        def paypal_items
          items = summary[:items]
          {items: items}
        end

        def ui_callback_params
          return {} unless allow_shipping_change && shipping_methods.count > 0
          { 
            callback_url: callback_url,
            callback_timeout: 6,
            callback_version: 95,
            max_amount: convert_amount((cart.total * 1.2) + shipping_methods.last.total + shipping_methods.last.tax) 
          }
        end

        # @method shipping_methods
        # 
        # @returns shipping methods with promotions applied
        def shipping_methods
          @shipping_methods ||= ShippingMethodsForCart.new(cart: cart, shipping_methods: shipping_method_model.all).call.sort_by(&:total)
        end

        def shipping_method
          cart.shipping_method || shipping_methods.first
        end

        def shipping_options_params
          return { shipping_options: [] } if !allow_shipping_change || shipping_method.nil?
          shipping_method_id = shipping_method.id
          {
              shipping_options: shipping_methods.map {|sm| {name: sm.label, amount: convert_amount(sm.total), default: sm.id == shipping_method_id, label: "#{sm.description}#{sm.id}"}}
          }
        end

        def summary
          @summary ||= GenerateSummary.new(cart: cart).call
        end

        def valid_shipping_method?
          return true if cart.shipping_method_id.nil? || shipping_methods.any? {|sm| sm.id == cart.shipping_method_id}
          payment_provider_setup.errors.add(:cart_id, I18n.t("payment_setup.shipping_method_not_available"))
          false
        end
      end
    end
  end
end