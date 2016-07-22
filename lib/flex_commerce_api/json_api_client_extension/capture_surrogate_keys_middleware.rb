# Adds surrogate keys header to all requests to Flex API.
module FlexCommerceApi
  module JsonApiClientExtension
    class CaptureSurrogateKeysMiddleware < ::Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |env|
          surrogate_keys = env.response_headers['external-surrogate-key'].split(' ') if env.response_headers['external-surrogate-key']

          if surrogate_keys
            if Thread.current[:shift_surrogate_keys].nil?
              Thread.current[:shift_surrogate_keys] = surrogate_keys
            else
              Thread.current[:shift_surrogate_keys] = Thread.current[:shift_surrogate_keys].push(*surrogate_keys)
            end
          end
        end
      end
    end
  end
end
