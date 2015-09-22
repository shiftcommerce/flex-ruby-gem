module FlexCommerceApi
  module JsonApiClientExtension
    #
    #
    class LoggingMiddleware < ::Faraday::Middleware
      attr_accessor :request_id, :logger
      def initialize(*args)
        super
        self.request_id = 0
        self.logger = FlexCommerceApi.logger
      end
      #
      #
      def call(env)
        self.request_id += 1
        @app.call(env).on_complete do |response_env|
          request_message = "#{env.method.to_s.upcase} #{env.url}"
          request_message << " - with request body - \n\t#{env[:request_body]}"
          response_message = "#{env.body}"
          logger.debug("FlexApi::Request::#{request_id}::#{request_message}")
          logger.debug("FlexApi::Response::#{request_id}\n\t#{response_message}")
        end
      end
    end
  end
end
