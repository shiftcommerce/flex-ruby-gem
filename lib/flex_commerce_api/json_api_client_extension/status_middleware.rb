module FlexCommerceApi
  module JsonApiClientExtension
    class StatusMiddleware < Faraday::Middleware
      def call(environment)
        request_env = environment.dup
        @app.call(environment).on_complete do |env|
          handle_status(env[:status], env, request_env)

          # look for meta[:status]
          if env[:body].is_a?(Hash)
            code = env[:body].fetch("meta", {}).fetch("status", 200).to_i
            handle_status(code, env, request_env)
          end
        end
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError
        raise Errors::ConnectionError, environment
      end

      protected

      def handle_status(code, env, request_environment)
        case code
          when 200..399
          when 403
            raise ::FlexCommerceApi::Error::AccessDenied.new request_environment, env
          when 404
            raise ::FlexCommerceApi::Error::NotFound, env[:url]
          when 400..499
            # some other error
          when 500..599
            raise ::FlexCommerceApi::Error::InternalServer.new request_environment, env
          else
            raise ::FlexCommerceApi::Error::UnexpectedStatus.new(code, env[:url])
        end
      end
    end
  end
end