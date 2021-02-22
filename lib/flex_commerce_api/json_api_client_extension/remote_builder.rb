module FlexCommerceApi
  module JsonApiClientExtension
    class RemoteBuilder < ::JsonApiClient::Query::Builder
      def initialize(klass, **keyword_arguments)
        super(klass)
        @connection = keyword_arguments[:connection]
        @path = keyword_arguments[:path]
      end

      def find(args = {})
        case args
        when Hash
          scope = where(args)
        else
          scope = _new_scope( primary_key: args )
        end

        get_request(scope.params)
      end

      private

      def get_request(params)
        klass.parser.parse(klass, connection.run(:get, path, params: params, headers: klass.custom_headers))
      end

      def _new_scope( opts = {} )
        self.class.new( @klass,
             primary_key:       opts.fetch( :primary_key, @primary_key ),
             pagination_params: @pagination_params.merge( opts.fetch( :pagination_params, {} ) ),
             path_params:       @path_params.merge( opts.fetch( :path_params, {} ) ),
             additional_params: @additional_params.merge( opts.fetch( :additional_params, {} ) ),
             filters:           @filters.merge( opts.fetch( :filters, {} ) ),
             includes:          @includes + opts.fetch( :includes, [] ),
             orders:            @orders + opts.fetch( :orders, [] ),
             fields:            @fields + opts.fetch( :fields, [] ),
             connection:        opts.fetch( :connection, connection),
             path:              opts.fetch( :path, path))
      end

      attr_accessor :path, :connection
    end
  end
end
