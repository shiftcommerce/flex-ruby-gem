# @module FlexCommerce::PaypalExpress::Process
module FlexCommerce
  module PaypalExpress
    module Process
      # @class ParseResponse
      class ParseResponse

        def initialize(response:, shipping_method_model: FlexCommerce::ShippingMethod)
          self.response = response
          self.shipping_method_model = shipping_method_model
        end

        def parse
          {
            shipping_method_id: get_shipping_method_details,
            email: get_email_address,
            shipping_address_attributes: get_shipping_address_attributes,
            billing_address_attributes: get_billing_address_attributes
          }
        end

        attr_accessor :response, :shipping_method_model

        private

        def get_shipping_method_details
          if response.params["shipping_option_name"]
            shipping_option_name = response.params["shipping_option_name"]
            shipping_method = find_shipping_method(shipping_option_name)
            raise "Shipping method #{response.params["shipping_option_name"]} not found\n\nExact response from paypal were: \n#{response.to_json}" unless shipping_method
            shipping_method.id
          else
            nil
          end
        end

        # Currently Paypal is returning only shipping method label.
        # And we cannot query for shipping method 
        def find_shipping_method(shipping_option_name)
          all_shipping_methods = shipping_method_model.all
          sm = all_shipping_methods.select { |sm| sm.label == shipping_option_name }.first
          sm ||= all_shipping_methods.select{ |sm| sm.label == de_dup_shipping_option_name(shipping_option_name) }.first
          sm
        end

        # COPIED this comments from flex-platform code
        # 
        # This is temporary but will do no harm if left in
        # When paypal calls the "callback url" to get the list of shipping options
        # then, the user clicks on "buy" - the resulting shipping method name is duplicated
        # so, if you had "Shipping method 1" - you would get "Shipping method 1 Shipping method 1"
        # This method looks for that duplication and removes it
        # @TODO Debug system thoroughly to find the root cause of this
        def de_dup_shipping_option_name(str)
          parts = str.split(" ")
          if parts.length.even?
            mid = parts.length / 2
            lft = parts[0...mid]
            right = parts[mid..-1]
            if lft == right
              lft.join(" ")
            else
              str
            end
          else
            str
          end
        end

        def get_shipping_address_attributes
          convert_address(response.params["PaymentDetails"]["ShipToAddress"])
        end

        def get_billing_address_attributes
          convert_address(response.params["PayerInfo"]["Address"])
        end

        def get_email_address
          response.params["PayerInfo"]["Payer"]
        end

        def convert_address(paypal_address)
          mapping = address_direct_mapping
          name_words = paypal_address["Name"].split(" ")
          attrs = {
              "first_name" => name_words.shift,
              "last_name" => name_words.pop || "",
              "middle_names" => name_words.join(" ")
          }
          paypal_address.inject(attrs) do |acc, (field, value)|
            if mapping.key?(field)
              acc.merge(mapping[field] => value || "")
            else
              acc
            end
          end
        end

        def address_direct_mapping
          {
            "Street1" => "address_line_1",
            "Street2" => "address_line_2",
            "CityName" => "city",
            "StateOrProvince" => "state",
            "Country" => "country",
            "PostalCode" => "postcode"
          }
        end
      end
    end
  end
end