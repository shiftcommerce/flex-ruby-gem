require "flex_commerce_api/v2/api_base"

module FlexCommerce
  module V2
    class Order < FlexCommerceApi::V2::ApiBase
      has_many :line_items, class_name: "::FlexCommerce::V2::LineItem"
    end
  end
end
