require "flex_commerce_api/oms/api_base"
require "flex_commerce_api/api_base"
module FlexCommerce
  module OMS
    class CustomerOrder < FlexCommerceApi::OMS::ApiBase
      has_many :payments, class_name: "::FlexCommerce::OMS::Payments"
      has_many :line_items, class_name: "::FlexCommerce::OMS::LineItem"
      has_many :discounts, class_name: "::FlexCommerce::OMS::Discount"
      has_many :shipping_address, class_name: "::FlexCommerce::OMS::Address"
      has_one :billing_address, class_name: "::FlexCommerce::OMS::Address"
      has_one :customer, class_name: "::FlexCommerce::OMS::Customer"
      has_one :shipping_method, class_name: "::FlexCommerce::OMS::ShippingMethod"
    end
  end
end
