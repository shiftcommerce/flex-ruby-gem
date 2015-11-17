require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce OrderShippingMethod model
  #
  # This model provides access to the flex commerce order shipping methods
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all order shipping methods for a customer account
  #
  #   FlexCommerce::ShippingMethod.all #fetches all order shipping methods(actually the first page in case there are thousands)
  #
  #
  class ShippingMethod < FlexCommerceApi::ApiBase

    # @method all
    # Returns all order shipping methods
    # @return [FlexCommerce::OrderShippingMethod[]] An array of order shipping methods or an empty array

  end
end
