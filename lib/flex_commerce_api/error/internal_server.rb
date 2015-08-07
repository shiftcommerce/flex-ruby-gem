module FlexCommerceApi
  module Error
    class InternalServer < Base
      def message
        "Internal server error"
      end

    end
  end
end