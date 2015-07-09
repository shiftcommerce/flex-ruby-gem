module FlexCommerceApi
  module JsonApiClientExtension
    #
    #
    # @!visibility private
    # This class is used internally to modify pagination parameters to
    # suit the flex platform.
    class PaginationMiddleware < ::Faraday::Middleware
      #
      # Looks for page[number] in the params, grabs the page number from it
      # removes it then puts the page number back into the path.
      # This is required by the flex platform to improve caching performance
      def call(env)
        params_hash = Addressable::URI.parse(env.url.to_s).query_values || {}
        env.url.tap do |url|
          page = params_hash.delete("page[number]")
          url.query = params_hash.empty? ? nil : params_hash.to_query
          url.path << "/pages/#{page}"
        end if params_hash.key?("page[number]")
        @app.call(env)
      end
    end
  end
end
