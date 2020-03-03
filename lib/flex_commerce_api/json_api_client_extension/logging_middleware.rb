module FlexCommerceApi
  module JsonApiClientExtension
    class LoggingMiddleware < ::Faraday::Middleware
      attr_accessor :request_id, :logger
      def initialize(*args)
        super
        self.request_id = 0
        self.logger = FlexCommerceApi.logger
      end

      def call(env)
        self.request_id += 1
        @app.call(env).on_complete do |response_env|
          logger.debug("FlexApi::Request  id #{request_id} #{env.method.to_s.upcase} #{env.url} started at #{Time.now}")
          logger.debug("\t >>> #{env[:request_body]}") unless env[:request_body].nil? || env[:request_body].empty?
          logger.debug("\t <<< (#{env[:status]}) #{env.body}")
        end
      end
    end
  end
end
