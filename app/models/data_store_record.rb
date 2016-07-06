require "flex_commerce_api/api_base"

module FlexCommerce
  class DataStoreRecord < FlexCommerceApi::ApiBase
    def self.table_name
      'generic_data_store/records'
    end

    self.query_builder = ::FlexCommerceApi::JsonApiClientExtension::Builder

    class << self
      def_delegators :_new_scope, :temp_search
    end
  end
end
