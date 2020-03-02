module FlexCommerceApi
  module JsonApiClientExtension
    # Looks for a lambda defined on the config, calls and assigns it to the
    # outgoing request headers
    class ForwardedForMiddleware < Faraday::Middleware
      def call(env)
        forwarded_for = FlexCommerceApi.config.forwarded_for

        if forwarded_for.respond_to?(:call)
          env[:request_headers]["X-Forwarded-For"] = forwarded_for.call
        end

        @app.call(env)
      end
    end
  end
end
