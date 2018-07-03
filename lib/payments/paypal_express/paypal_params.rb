require_relative 'api'

# @module FlexCommerce::Payments::PaypalExpress::Api
module FlexCommerce
  module Payments
    module PaypalExpress
      class PaypalParams
        include ::FlexCommerce::Payments::PaypalExpress::Api

        DEFAULT_DESCRIPTION = "Shift Commerce Order".freeze
        
        def initialize(cart:,success_url:, cancel_url:, ip_address:, allow_shipping_change: true, callback_url:, shipping_method_model: FlexCommerce::ShippingMethod, use_mobile_payments: false, description: nil)
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
          base_paypal_params
            .merge(paypal_shipping_address_params)
            .merge(paypal_items)
            .merge(ui_callback_params)
            .merge(shipping_options_params)
        end

        attr_accessor :description, :cart, :success_url, :cancel_url, :ip_address, :allow_shipping_change, :callback_url, :shipping_method_model, :use_mobile_payments

        private

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
            description: description || DEFAULT_DESCRIPTION,
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
      end
    end
  end
end