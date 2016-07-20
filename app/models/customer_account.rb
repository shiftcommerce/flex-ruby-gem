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
    has_many :addresses, class_name: "::FlexCommerce::Address"
    has_many :customer_segments, class_name: "::FlexCommerce::CustomerSegment"
    has_many :notes, class_name: "::FlexCommerce::Note"

    property :email, type: :string
    property :reference, type: :string
    property :password, type: :string


    def self.authenticate(attributes)
      requestor.custom("authentications", {request_method: :post}, {data: {type: :customer_accounts, attributes: attributes}}).first
    rescue ::FlexCommerceApi::Error::NotFound
      nil
    end

    def self.find_by_email(email)
      requestor.custom("email:#{URI.encode_www_form_component(email)}", {request_method: :get}, {}).first
    rescue ::FlexCommerceApi::Error::NotFound
      nil
    end

    def self.find_by_reference(reference)
      requestor.custom("reference:#{reference}", {request_method: :get}, {}).first
    rescue ::FlexCommerceApi::Error::NotFound
      nil
    end

    def self.generate_token(attributes)
      post_attributes = { reset_link_with_placeholder: attributes[:reset_link_with_placeholder] }
      requestor.custom("email:#{URI.encode_www_form_component(attributes[:email])}/resets", { request_method: :post }, { data: { type: :customer_accounts, attributes: post_attributes } }).first
    end

    def self.reset_password(attributes)
      patch_attributes = { password: attributes[:password] }
      result = requestor.custom("email:#{URI.encode_www_form_component(attributes[:email])}/resets/token:#{attributes[:reset_password_token]}", { request_method: :patch }, { data: { type: :customer_accounts, attributes: patch_attributes } }).first
      # Need to return object with an error in case of 422 status code
      # @TODO refactor this method and 'generate_token' method to be an instance methods and update api accordingly
      unless result
        error_response = connection.last_response
        result = find_by_email(attributes[:email])
        if result && error_response.status == 422
          error_response.body["errors"].each { |e| result.errors.add(:reset_password_token, e["detail"]) }
        end
      end
      result
    end

    def orders
      ::FlexCommerce::Order.where(customer_account_id: id)
    end

    def create_note(attributes = {})
      ::FlexCommerce::Note.create(attributes.merge(attached_to_id: self.id, attached_to_type: self.class.name.demodulize))
    end
  end
end
