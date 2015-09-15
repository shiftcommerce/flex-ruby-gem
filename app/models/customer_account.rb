require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Customer Account model
  #
  # This model provides access to the flex commerce customer account and associated cart.
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Creating an account
  #
  #   FlexCommerce::CustomerAccount.create #creates and returns a new account ready for use
  #
  #   # Fetching its cart
  #
  #   account.cart
  #
  #   # Finding an account
  #
  #   FlexCommerce::CustomerAccount.find(<<customer_account_id>>) # Finds the account with this unique id
  #
  #
  class CustomerAccount < FlexCommerceApi::ApiBase
    # @method find
    # @param [String] spec
    # Finds an account
    # @return [FlexCommerce::CustomerAccount] customer_account The customer account
    # @raise [FlexCommerceApi::Error::NotFound] If not found

    # @method cart
    # Provides access to the customers cart
    # @return FlexCommerce::Cart

    # @TODO Document other popular methods that we will support

    has_one :cart, class_name: "::FlexCommerce::Cart"

  end
end
