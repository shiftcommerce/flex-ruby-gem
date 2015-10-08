module FlexCommerceApi
  module JsonApiClientExtension
    class Builder < ::JsonApiClient::Query::Builder
      def initialize(*)
        super
        @temp_search_criteria = nil
      end
      def temp_search(options = {})
        @temp_search_criteria = options
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
    end
  end
end
