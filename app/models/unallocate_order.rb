require "flex_commerce_api/api_base"
module FlexCommerce
  class UnallocateOrder < FlexCommerceApi::ApiBase
    def self.table_name
      "unallocate_order"
    end
  end
end
