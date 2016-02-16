require "rack/utils"

# Adds preview param to all requests to Flex API.
module FlexCommerceApi
  module JsonApiClientExtension
    class PreviewedRequestMiddleware < ::Faraday::Middleware
      def call(env)
        env.url.tap do |url|
          parsed_query = Rack::Utils.parse_nested_query url.query
          parsed_query[:preview] = true
          url.query = parsed_query.to_param
        end
        @app.call(env)
      end
    end
  end
end
