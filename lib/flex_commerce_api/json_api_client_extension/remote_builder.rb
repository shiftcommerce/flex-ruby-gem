module FlexCommerceApi
  module JsonApiClientExtension
    class RemoteBuilder < ::JsonApiClient::Query::Builder
      def initialize(klass, path: klass.path, connection: klass.connection)
        super(klass)
        self.connection = connection
        self.path = path
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
        p path
        klass.parser.parse(klass, connection.run(:get, path, params, klass.custom_headers))
      end
      attr_accessor :path, :connection
    end
  end
end
