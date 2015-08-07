module FlexCommerceApi
  module Error
    class NotFound < InternalServer
      attr_reader :uri
      def initialize(uri)
        @uri = uri
      end
      def message
        "Couldn't find resource at: #{uri.to_s}"
      end
    end
  end
end