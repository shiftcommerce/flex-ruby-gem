require "json_api_client"
require "faraday/request/basic_authentication"
require "uri"
require "flex_commerce_api/json_api_client_extension/paginator"
require "flex_commerce_api/json_api_client_extension/pagination_middleware"
require "flex_commerce_api/json_api_client_extension/json_format_middleware"
require "flex_commerce_api/json_api_client_extension/has_many_association_proxy"
module FlexCommerceApi
  #
  # Base class for all flex commerce models
  #
  class ApiBase < JsonApiClient::Resource
    PRIVATE_ATTRIBUTES = %w(id type relationships links meta)
    # set the api base url in an abstract base class
    self.site = FlexCommerceApi.config.api_base_url
    self.paginator = JsonApiClientExtension::Paginator
    class << self
      # @method all
      # Returns all resources
      # @return [FlexCommerceApi::ApiBase[]] An array of resources or an empty array

      # @method paginate
      # Paginates the list of resources by a preset page size
      # @param [Hash] options The options to paginate with
      # @param options [Numeric|String] :page The page to fetch

      # @method find
      # @param [String] spec The spec of what to find
      #
      # Finds a resource
      # @return [FlexCommerceApi::ApiBase] resource The resource found
      # @raise [FlexCommerceApi::Error::NotFound] If not found
      def find(*args)
        # This is required as currently the underlying gem returns an array
        # even if 1 record is found.  This is inconsistent with active record
        result = super
        result.length <= 1 ? result.first : result
      end

      # The username to use for authentication.  This is the same as
      # the account name from the flex platform.
      # @return [String] The username
      def username
        URI.parse(site).path.split("/").reject(&:empty?).first
      end

      # The password to use for authentication.  This is the same as
      # the access key token from the flex platform.
      # @return [String] The password
      def password
        FlexCommerceApi.config.flex_api_key
      end
    end

    def public_attributes
      attributes.reject { |k, v| PRIVATE_ATTRIBUTES.include?(k.to_s) }
    end

    private

    # This is temporary code - eventually this will be in the lower level gem
    def has_many_association_proxy(assoc_name, real_instance)
      JsonApiClientExtension::HasManyAssociationProxy.new(real_instance, self, assoc_name)
    end

  end
  ApiBase.connection do |connection|
    connection.faraday.basic_auth(ApiBase.username, ApiBase.password)
    connection.use JsonApiClientExtension::PaginationMiddleware
    connection.use JsonApiClientExtension::JsonFormatMiddleware
  end
end
