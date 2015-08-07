module FlexCommerceApi
  module JsonApiClientExtension
    #
    #
    # @!visibility private
    # This class is used internally to save the request body as it
    # gets replaced by the response body.
    # The result can then be evaluated by an exception handler to show
    # the request and response to the developer.
    class SaveRequestBodyMiddleware < ::Faraday::Middleware
      #
      # Saves the request body in env[:request_body]
      #
      def call(env)
        env[:request_body] = env[:body]
        @app.call(env)
      end
    end
  end
end
