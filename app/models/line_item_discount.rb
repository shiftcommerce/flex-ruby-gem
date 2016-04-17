require "flex_commerce_api/api_base"

module FlexCommerce
  class LineItemDiscount < FlexCommerceApi::ApiBase
    has_one :promotion
  end
end
