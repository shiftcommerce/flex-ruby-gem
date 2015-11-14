module FlexCommerceApi
  module JsonApiClientExtension
    class FlexibleConnection < JsonApiClient::Connection
      def initialize(options = {})
        site = options.fetch(:site)
        adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
        @faraday = Faraday.new(site) do |builder|
          builder.request :json
          builder.use JsonApiClientExtension::SaveRequestBodyMiddleware
          builder.use JsonApiClientExtension::LoggingMiddleware unless FlexCommerceApi.logger.nil?
          builder.use JsonApiClientExtension::PaginationMiddleware
          builder.use JsonApiClientExtension::JsonFormatMiddleware
          builder.use JsonApiClient::Middleware::JsonRequest
          builder.use JsonApiClientExtension::StatusMiddleware
          builder.use JsonApiClient::Middleware::ParseJson
          builder.adapter *adapter_options
        end
        faraday.basic_auth(ApiBase.username, ApiBase.password)

        yield(self) if block_given?
      end
    end
  end
end


