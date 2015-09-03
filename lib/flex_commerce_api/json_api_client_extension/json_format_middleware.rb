module FlexCommerceApi
  module JsonApiClientExtension
    #
    #
    # @!visibility private
    # This class is used internally to modify the URL to have .json at the end to
    # suit the flex platform.
    class JsonFormatMiddleware < ::Faraday::Middleware
      #
      # Adds .json to the URL before it gets sent
      #
      def call(env)
        env.url.tap do |url|
          url.path << ".json_api" unless url.path=~/\.json_api$/
        end
        @app.call(env)
      end
    end
  end
end
