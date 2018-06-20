require "flex_commerce_api/api_base"
module FlexCommerce
  class ImportEntry < FlexCommerceApi::ApiBase
    belongs_to :import, class_name: "FlexCommerce::Import"
  end
end
