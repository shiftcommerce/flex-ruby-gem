require "json_api_client"
require "faraday/request/basic_authentication"
require "uri"
require "active_support/core_ext/hash/indifferent_access"
require "flex_commerce_api/json_api_client_extension/paginator"
require "flex_commerce_api/json_api_client_extension/requestor"
require "flex_commerce_api/json_api_client_extension/save_request_body_middleware"
require "flex_commerce_api/json_api_client_extension/logging_middleware"
require "flex_commerce_api/json_api_client_extension/status_middleware"
require "flex_commerce_api/json_api_client_extension/json_format_middleware"
require "flex_commerce_api/json_api_client_extension/previewed_request_middleware"
require "flex_commerce_api/json_api_client_extension/has_many_association_proxy"
require "flex_commerce_api/json_api_client_extension/builder"
require "flex_commerce_api/json_api_client_extension/flexible_connection"
require "flex_commerce_api/json_api_client_extension/resource"
module FlexCommerceApi
  #
  # Base class for all flex commerce models
  #
  class ApiBase < ::FlexCommerceApi::JsonApiClientExtension::Resource
    PRIVATE_ATTRIBUTES = %w(id type relationships links meta)
    RELATED_META_RESOURCES = %w(related-categories related-static_pages related-resources related-files related-products)
    # set the api base url in an abstract base class
    self.paginator = JsonApiClientExtension::Paginator
    self.requestor_class = JsonApiClientExtension::Requestor
    self.connection_class = ::FlexCommerceApi::JsonApiClientExtension::FlexibleConnection

    class << self
      def create!(*args)
        create(*args).tap do |resource|
          raise(::FlexCommerceApi::Error::RecordInvalid.new(resource)) unless resource.errors.empty?
        end
      end
      # @method all
      # Returns all resources
      # @return [FlexCommerceApi::ApiBase[]] An array of resources or an empty array

      # @method paginate
      # Paginates the list of resources by a preset page size
      # @param [Hash] options The options to paginate with
      # @param options [Numeric|String] :page The page to fetch

      # @method find_all
      # Finds many resources, always returning an array, even if 1 result
      alias_method :find_all, :find

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

      # The username to use for authentication.
      # @return [String] The username
      def username
        username = FlexCommerceApi.config.flex_account
        username = URI.parse(site).path.split("/").reject(&:empty?).first if username.nil? || username.empty?
        username
      end

      # The password to use for authentication.  This is the same as
      # the access key token from the flex platform.
      # @return [String] The password
      def password
        FlexCommerceApi.config.flex_api_key
      end

      def path(params = nil, record = nil)
        super(params)
      end

      def reconfigure_all options = {}
        subclasses.each do |sub|
          sub.reconfigure options
        end
        reconfigure options
      end

      def reconfigure options = {}
        self.site = FlexCommerceApi.config.api_base_url
        adapter_options = { adapter: FlexCommerceApi.config.adapter || :net_http }
        http_cache_options = { http_cache: FlexCommerceApi.config.http_cache }
        self.connection_options.delete(:include_previewed)
        self.connection_options = connection_options.merge(adapter_options).merge(http_cache_options).merge(options)
        reload_connection_if_required
      end

      def reload_connection_if_required
        _build_connection(true) if connection_object
      end
    end

    reconfigure

    # Ensures all attributes are with indifferent access
    def initialize(attrs = {})
      super attrs.with_indifferent_access
    end

    def save!
      return if save
      raise_record_invalid
    end

    def public_attributes
      attributes.reject { |k, v| PRIVATE_ATTRIBUTES.include?(k.to_s) }
    end

    def meta_attribute(key)
      begin
        return self.send(key) if RELATED_META_RESOURCES.include?(attributes[:meta_attributes][key][:data_type])
        attributes[:meta_attributes][key][:value]
      rescue NoMethodError => e
        nil
      end
    end

    def template_attribute(key)
      begin
        return self.send("template_#{key}") if RELATED_META_RESOURCES.include?(attributes[:template_attributes][key][:data_type])
        attributes[:template_attributes][key][:value]
      rescue NoMethodError => e
        nil
      end
    end

    def method_missing(method, *args)
      if relationships and relationships.has_attribute?(method)
        super
      else
        has_attribute?(method) || method.to_s=~(/=$/) || method.to_s=~/!$/ ? super : nil
      end
    end

    private

    def raise_record_invalid
      raise(::FlexCommerceApi::Error::RecordInvalid.new(self))
    end

    # This is temporary code - eventually this will be in the lower level gem
    def has_many_association_proxy(assoc_name, real_instance, options = {})
      JsonApiClientExtension::HasManyAssociationProxy.new(real_instance, self, assoc_name, options)
    end

  end
end
