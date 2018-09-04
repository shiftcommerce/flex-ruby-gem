module FlexCommerceApi
  module JsonApiClientExtension
    class RemoteBuilder < ::JsonApiClient::Query::Builder
      def initialize(klass, opts = {})
        super(klass, opts)
        self.connection = opts.fetch(:connection, klass.connection)
        self.path = opts.fetch(:path, klass.path)
      end

      def find(args = {})
        case args
          when Hash
            where(args)
          else
            @primary_key = args
        end

        get_request(params)
      end

      private

      def get_request(params)
        klass.parser.parse(klass, connection.run(:get, path, params, klass.custom_headers))
      end
      attr_accessor :path, :connection
    end
  end
end
