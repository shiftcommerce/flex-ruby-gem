module FlexCommerceApi
  module Error
    class BadRequest < ClientError
      def message
        "Bad Request "
      end
    end
  end
end