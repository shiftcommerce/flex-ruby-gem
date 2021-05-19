require "flex_commerce_api/oms/api_base"

module FlexCommerce
  module OMS
    class BillingAddress < FlexCommerceApi::OMS::ApiBase
      belongs_to :customer_order, class_name: "::FlexCommerce::OMS::CustomerOrder"
    end
  end
end
