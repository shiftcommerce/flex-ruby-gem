require 'faraday-http-cache'

module FlexCommerceApi
  module JsonApiClientExtension
    class FlexibleConnection < JsonApiClient::Connection
      attr_accessor :last_response
      def initialize(options = {})
        site = options.fetch(:site)
        adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
        include_previewed = options.fetch :include_previewed, false
        @faraday = Faraday.new(site) do |builder|
          builder.request :json
          builder.use JsonApiClientExtension::SaveRequestBodyMiddleware
          builder.use JsonApiClientExtension::JsonFormatMiddleware
          builder.use JsonApiClientExtension::PreviewedRequestMiddleware if include_previewed
          builder.use JsonApiClient::Middleware::JsonRequest
          builder.use :http_cache, cache_options(options)
          builder.use JsonApiClientExtension::StatusMiddleware
          builder.use JsonApiClient::Middleware::ParseJson
          builder.adapter *adapter_options
          builder.use JsonApiClientExtension::LoggingMiddleware unless FlexCommerceApi.logger.nil?
        end
        faraday.basic_auth(ApiBase.username, ApiBase.password)

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
    end
  end
end
