require "colorize"
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
          request_header_message = "#{env.method.to_s.upcase} #{env.url}".colorize(color: :magenta, background: :white)
          request_message = "#{env[:request_body]}"
          response_message = "#{env.body}".colorize(color: :red, background: :white)
          logger.debug("FlexApi::Request  id #{request_id} #{request_header_message} started at #{Time.now}")
          logger.debug("\t >>> #{request_message}")
          logger.debug("\t <<< #{response_message}")
        end
      end
    end
  end
end
