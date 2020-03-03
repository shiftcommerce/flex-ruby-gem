require "flex_commerce_api/api_base"

module FlexCommerce
  class DataStoreType < FlexCommerceApi::ApiBase
    def self.table_name
      "generic_data_store/record_types"
    end
  end
end
