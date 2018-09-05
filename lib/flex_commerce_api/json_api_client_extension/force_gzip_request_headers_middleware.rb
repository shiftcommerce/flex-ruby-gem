# Adds Accept-Encoding: gzip header to all requests to Flex API.
module FlexCommerceApi
  module JsonApiClientExtension
    class ForceGzipRequestHeadersMiddleware < ::Faraday::Middleware
      def call(env)
        puts "==== OLD HEADERS: #{env[:request_headers]}"
        env[:request_headers].merge!("Accept-Encoding" => "gzip")
        puts "==== NEW HEADERS: #{env[:request_headers]}"

        @app.call(env)
      end
    end
  end
end
