require 'faraday-http-cache'

module FlexCommerceApi
  module JsonApiClientExtension
    class FlexibleConnection < JsonApiClient::Connection
      attr_accessor :last_response
      def initialize(options = {})
        site = options.fetch(:site)
        adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
        add_json_api_extension = options.fetch(:add_json_api_extension, true)
        authenticate = options.fetch(:authenticate, true)
        include_previewed = options.fetch :include_previewed, false

        @faraday = Faraday.new(site) do |builder|
          builder.request :json
          builder.use FaradayMiddleware::Gzip if gzip_enabled?(adapter_options)
          builder.use JsonApiClientExtension::SaveRequestBodyMiddleware
          builder.use JsonApiClientExtension::JsonFormatMiddleware if add_json_api_extension
          builder.use JsonApiClientExtension::PreviewedRequestMiddleware if include_previewed
          builder.use JsonApiClient::Middleware::JsonRequest
          # Surrogate Key middleware should always be above HTTP caching to ensure we're reading headers
          # from the original response not the 304 responses
          builder.use JsonApiClientExtension::CaptureSurrogateKeysMiddleware
          # disable the cache when HTTP cache is set to false
          unless false == options[:http_cache]
            builder.use :http_cache, cache_options(options)
          end
          builder.use JsonApiClientExtension::StatusMiddleware
          builder.use JsonApiClient::Middleware::ParseJson
          builder.use JsonApiClientExtension::LoggingMiddleware unless FlexCommerceApi.logger.nil?
          builder.adapter *adapter_options
          builder.options[:open_timeout] = options.fetch(:open_timeout)
          builder.options[:timeout] = options.fetch(:timeout)
        end
        faraday.basic_auth(ApiBase.username, ApiBase.password) if authenticate

        yield(self) if block_given?
      end

      def run(*args)
        super.tap do |response|
          self.last_response = response
        end
      end

      private

      def cache_options(options)
        {
          # treats the cache like a client, not a proxy
          shared_cache: false,
          # use the Rails cache, if set, otherwise default to MemoryStore
          store: defined?(::Rails) ? ::Rails.cache : nil,
          # serialize the data using Marshal
          serializer: Marshal,
          # use our configured logger
          logger: FlexCommerceApi.logger
        }.merge(options.fetch(:http_cache, {}))
      end

      def gzip_enabled?(adapter_options)
        # We know gzip compression works with net_http and typhoeus adapters,
        # but not rack for example, so we whitelist supported adapters here:
        supported_adapters = [:net_http, :typhoeus]
        adapter_supported = (adapter_options & supported_adapters).any?

        # Gzip is enabled if the adapter supports it and we aren't explicitly
        # disabling gzip in the gem config
        adapter_supported && !FlexCommerceApi.config.disable_gzip
      end
    end
  end
end
