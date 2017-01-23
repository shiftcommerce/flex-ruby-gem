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
    has_many :orders, class_name: "::FlexCommerce::RemoteOrder"
    has_one :password_recovery, class_name: "::FlexCommerce::PasswordRecovery"

    property :email, type: :string
    property :reference, type: :string
    property :password, type: :string


    def self.authenticate(attributes = {})
      FlexCommerce::CustomerAccountAuthentication.create(attributes).customer_account
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

    # Find customer account by password reset token provided in email's link
    # Used in reset password scenario
    def self.find_by_token(token)
      requestor.custom("token:#{token}", {request_method: :get}, {}).first
    rescue ::FlexCommerceApi::Error::NotFound
      nil
    end

    def generate_token(attributes)
      ::FlexCommerce::PasswordRecovery.create(attributes.merge(customer_account_id: id))
    end

    def reset_password(attributes)
      password_recovery.id = nil # because it is singletone resource, otherwise id is injected into path
      password_recovery.update(attributes.merge(customer_account_id: id))
      password_recovery
    end

    def orders
      return super if relationships[:orders].key?("data")
      get_related(:orders)
    end

    def create_note(attributes = {})
      ::FlexCommerce::Note.create(attributes.merge(attached_to_id: self.id, attached_to_type: self.class.name.demodulize))
    end
  end
end
