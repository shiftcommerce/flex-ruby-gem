require "flex_commerce_api/api_base"

module FlexCommerce
  class DataStoreRecord < FlexCommerceApi::ApiBase
    def self.table_name
      "generic_data_store/records"
    end
  end
end
