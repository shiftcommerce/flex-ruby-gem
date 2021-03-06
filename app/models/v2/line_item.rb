require "flex_commerce_api/v2/api_base"

module FlexCommerce
  module V2
    class LineItem < FlexCommerceApi::V2::ApiBase
      belongs_to :order, class_name: "::FlexCommerce::V2::Order"
    end
  end
end
