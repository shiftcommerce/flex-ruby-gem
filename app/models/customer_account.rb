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

    property :email, type: :string
    property :reference, type: :string
    property :password, type: :string


    def self.authenticate(attributes)
      requestor.custom("authentications", {request_method: :post}, {data: {type: :customer_accounts, attributes: attributes}}).first
    rescue ::FlexCommerceApi::Error::NotFound
      nil
    end

    def self.generate_token(attributes)
      post_attributes = { reset_link_with_placeholder: attributes[:reset_link_with_placeholder] }
      requestor.custom("email:#{URI.escape(attributes[:email], "@.")}/resets", { request_method: :post }, { data: { type: :customer_accounts, attributes: post_attributes } }).first
    end

    def self.reset_password(attributes)
      patch_attributes = { password: attributes[:password] }
      requestor.custom("email:#{URI.escape(attributes[:email], "@.")}/resets/token:#{attributes[:reset_password_token]}", { request_method: :patch }, { data: { type: :customer_accounts, attributes: patch_attributes } }).first
    end
  end
end
