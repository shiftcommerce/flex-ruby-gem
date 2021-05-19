# @module FlexCommerce::PaypalExpress::Process
module FlexCommerce
  module PaypalExpress
    module Process
      # @class ResponseParser
      class ResponseParser

        def initialize(response:, shipping_method_model:)
          self.response = response
          self.shipping_method_model = shipping_method_model
        end

        # @TODO: Need to validate the paypal response, to ensure it is
        #        returning all the attribute values as expected
        # Related ticket: https://github.com/shiftcommerce/flex-ruby-gem/issues/152
        # 
        def call
          {
            shipping_method_id: get_shipping_method_details,
            email: get_email_address,
            shipping_address_attributes: get_shipping_address_attributes,
            billing_address_attributes: get_billing_address_attributes,
            payment_details: response.params["PaymentDetails"]
          }
        end

        attr_accessor :response, :shipping_method_model

        private

        # @method get_shipping_method_details
        # 
        # Currently, Paypal will only return the shipping_option_name param
        # which contains the shipping method label. Using this, we need to find
        # the shipping method id and return it.
        # @TODO: Incase of its missing, currently we are returning nil value. But ideally 
        # we have to log this error, just to ensure it is not platform issue.
        #  
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

        # @!visibility private
        # 
        # Currently Paypal is returning only shipping method label.
        # And we cannot query for shipping method by using the label, so 
        # We are fetching all the shipping methods and filtering them by label
        # 
        def find_shipping_method(shipping_option_name)
          all_shipping_methods = shipping_method_model.all
          sm = all_shipping_methods.select { |sm| sm.label == shipping_option_name }.first
          sm ||= all_shipping_methods.select{ |sm| sm.label == de_dup_shipping_option_name(shipping_option_name) }.first
          sm
        end

        # @!visibility private
        # 
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

        # @method get_shipping_address_attributes
        # 
        # Paypal will return shipping address in PaymentDetails.ShipToAddress Object
        # 
        def get_shipping_address_attributes
          convert_address(response.params["PaymentDetails"]["ShipToAddress"])
        end

        # @method get_billing_address_attributes
        # 
        # Paypal will return shipping address in PayerInfo.Address Object
        # 
        def get_billing_address_attributes
          convert_address(response.params["PayerInfo"]["Address"])
        end

        # @method get_billing_address_attributes
        # 
        # Paypal will return shipping address in PayerInfo.Payer Object
        # 
        def get_email_address
          response.params["PayerInfo"]["Payer"]
        end

        # @!visibility private
        # 
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

        # @!visibility private
        # 
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