module FlexCommerceApi
  module JsonApiClientExtension
    class Builder < ::JsonApiClient::Query::Builder
      def initialize(klass, opts = {})
        super
        @temp_search_criteria = opts.fetch(:temp_search_criteria, nil)
      end

      def temp_search(options = {})
        @temp_search_criteria = options
        self
      end

      def find(args = {})
        case args
        when Hash
          scope = where(args)
        else
          scope = _new_scope( primary_key: args )
        end
        if @temp_search_criteria.nil?
          klass.requestor.get(scope.params)
        else
          klass.requestor.custom(:search, { request_method: :get }, scope.params.merge(filter: @temp_search_criteria))
        end
      end

      private

      def _new_scope( opts = {} )
        self.class.new( @klass,
             primary_key:           opts.fetch( :primary_key, @primary_key ),
             pagination_params:     @pagination_params.merge( opts.fetch( :pagination_params, {} ) ),
             path_params:           @path_params.merge( opts.fetch( :path_params, {} ) ),
             additional_params:     @additional_params.merge( opts.fetch( :additional_params, {} ) ),
             filters:               @filters.merge( opts.fetch( :filters, {} ) ),
             includes:              @includes + opts.fetch( :includes, [] ),
             orders:                @orders + opts.fetch( :orders, [] ),
             fields:                @fields + opts.fetch( :fields, [] ),
             temp_search_criteria:  @temp_search_criteria,
          )
      end
    end
  end
end
