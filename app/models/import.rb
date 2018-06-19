require "flex_commerce_api/api_base"
module FlexCommerce
  class Import < FlexCommerceApi::ApiBase
    has_many :import_entries, class_name: "FlexCommerce::ImportEntry"
  end
end
