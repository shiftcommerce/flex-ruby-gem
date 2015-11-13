module FlexCommerceApi
  module JsonApiClientExtension
    # @!visibility private
    # This class overrides the default paginator to allow for
    # the custom things that are required by the flex platform.
    # This class is private and should not be used by end users
    class Paginator < ::JsonApiClient::Paginating::Paginator
      protected

      # This method is overriden as the flex URI's may have /pages/page_number
      # appended to any collection resource url.
      # whereas the rest of the pagination code works by fetching the page
      # number from the query params.  So, here we return the page number
      # as if it came from the query params.
      # Also, the json-api spec says this can be a hash with href containing the uri
      # so we allow for this also.
      #
      def params_for_uri(uri)
        return {} unless uri
        uri = URI.parse(uri["href"] || uri) unless uri.respond_to?(:scheme)
        (Addressable::URI.parse(uri).query_values || {}).merge(params_from_pagination(uri))
      end

      private

      # Gets the pagination parameters (currently only 'page') in the
      # form of a Hash
      # @param [URI::Generic] uri The uri to use
      # @return [Hash] The params
      def params_from_pagination(uri)
        page = uri.path.match(/\/pages\/(\d+)(?:\.\S*)?$/) { |match_data| match_data[1] }
        page.present? ? { "page" => page.to_i } : {}
      end
    end
  end
end
