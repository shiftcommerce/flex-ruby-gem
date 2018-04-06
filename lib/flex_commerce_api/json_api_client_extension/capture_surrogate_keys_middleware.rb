# Captures surrogate keys headers and collects them for passing to the client.
module FlexCommerceApi
  module JsonApiClientExtension
    class CaptureSurrogateKeysMiddleware < ::Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |env|
          surrogate_keys = env.response_headers['external-surrogate-key'].split(' ') if env.response_headers['external-surrogate-key']

          if surrogate_keys && Thread.current[:shift_surrogate_keys]
            Thread.current[:shift_surrogate_keys].concat(surrogate_keys)
          end
        end
      end
    end
  end
end
