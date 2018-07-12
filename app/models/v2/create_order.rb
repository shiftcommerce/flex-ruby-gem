require "flex_commerce_api/v2/api_base"
module FlexCommerce
  module V2
    class CreateOrder < FlexCommerceApi::V2::ApiBase
      def self.table_name
        "create_order"
      end
    end
  end
end
