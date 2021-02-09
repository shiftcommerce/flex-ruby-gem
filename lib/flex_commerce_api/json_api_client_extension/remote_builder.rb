module FlexCommerceApi
  module JsonApiClientExtension
    class RemoteBuilder < ::JsonApiClient::Query::Builder
      def initialize(klass, opts = {}, path: klass.path, connection: klass.connection)
        super(klass)
        self.connection = connection
        self.path = path
        @primary_key       = opts.fetch(:primary_key, nil)
        @pagination_params = opts.fetch(:pagination_params, {})
        @path_params       = opts.fetch(:path_params, {})
        @additional_params = opts.fetch(:additional_params, {})
        @filters           = opts.fetch(:filters, {})
        @includes          = opts.fetch(:includes, [])
        @orders            = opts.fetch(:orders, [])
        @fields            = opts.fetch(:fields, [])
      end

      def find(args = {})
        case args
          when Hash
            scope = where(args)
          else
            scope = _new_scope(primary_key: args)
        end

        get_request(scope.params)
      end

      private

      def _new_scope( opts = {} )
        self.class.new(
          @klass,
          primary_key:       opts.fetch(:primary_key, @primary_key),
          pagination_params: @pagination_params.merge(opts.fetch(:pagination_params, {})),
          path_params:       @path_params.merge(opts.fetch(:path_params, {})),
          additional_params: @additional_params.merge(opts.fetch(:additional_params, {})),
          filters:           @filters.merge(opts.fetch(:filters,{})),
          includes:          @includes + opts.fetch(:includes, []),
          orders:            @orders + opts.fetch(:orders, []),
          fields:            @fields + opts.fetch(:fields, [])
        )
      end

      def get_request(params)
        klass.parser.parse(klass, connection.run(:get, path, params, klass.custom_headers))
      end
      attr_accessor :path, :connection
    end
  end
end
