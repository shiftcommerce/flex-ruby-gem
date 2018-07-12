require "flex_commerce_api/v2/api_base"
module FlexCommerce
  module V2
    class DeallocateOrder < FlexCommerceApi::V2::ApiBase
      def self.table_name
        "deallocate_order"
      end
    end
  end
end
