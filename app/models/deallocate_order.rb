require "flex_commerce_api/api_base"
module FlexCommerce
  class DeallocateOrder < FlexCommerceApi::ApiBase
    def self.table_name
      "deallocate_order"
    end
  end
end
