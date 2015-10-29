require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Address model
  #
  # This model provides access to the flex commerce addresses
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all addresses for a customer account
  #
  #   customer_account.addresses.all #fetches all addresses(actually the first page in case there are thousands)
  #
  #
  class Address < FlexCommerceApi::ApiBase
    belongs_to :customer_account, class_name: "::FlexCommerce::CustomerAccount"

    # @method all
    # Returns all addresses
    # @return [FlexCommerce::Address[]] An array of categories or an empty array

  end
end
