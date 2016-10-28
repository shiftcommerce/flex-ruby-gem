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

      relationship_definitions = relationships[:orders]

      # look in included data
      if relationship_definitions.key?("data")
        return last_result_set.included.data_for(:orders, relationship_definitions)
      end

      if association = association_for(:orders)
        # look for a defined relationship url
        if relationship_definitions["links"] && url = relationship_definitions["links"]["related"]
          url = URI.parse(relationship_definitions["links"]["related"])
          site = url.clone.tap {|u|
            u.path = ""
            u.query = nil
            u.fragment = nil
          }.to_s
          path = url.clone.tap {|u|
            u.scheme = nil
            u.host = nil
            u.port = nil
            u.userinfo = nil
          }.to_s

          connection = FlexCommerceApi::JsonApiClientExtension::FlexibleConnection.new(self.class.connection_options.merge(site: site, add_json_api_extension: false, authenticate: false))
          RemoteOrder.parser.parse(RemoteOrder, connection.run(:get, path, {}, {}))
        end
      end
    end

    def create_note(attributes = {})
      ::FlexCommerce::Note.create(attributes.merge(attached_to_id: self.id, attached_to_type: self.class.name.demodulize))
    end
  end
end
