module FlexCommerceApi
  module JsonApiClientExtension
    class Builder < ::JsonApiClient::Query::Builder
      def initialize(*)
        super
        @temp_search_criteria = nil
      end
      def temp_search(options = {}, available_to_browse_only=true)
        @temp_search_criteria = options
        apply_available_to_browse_filter if available_to_browse_only
        self
      end

      def find(args = {})
        case args
          when Hash
            where(args)
          else
            @primary_key = args
        end
        if @temp_search_criteria.nil?
          klass.requestor.get(params)
        else
          klass.requestor.custom(:search, { request_method: :get }, params.merge(filter: @temp_search_criteria))
        end
      end

      private

      def apply_available_to_browse_filter
        @temp_search_criteria[:filter]=search_filters.merge({ "available_to_browse" => { "eq" => true } })
      end

      def search_filters
        search_filters = @temp_search_criteria[:filter]
        search_filters.is_a?(String) ? JSON.parse(search_filters) : search_filters
      end
    end
  end
end
