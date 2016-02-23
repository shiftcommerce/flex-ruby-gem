require "flex_commerce_api/api_base"

module FlexCommerce
  class User < FlexCommerceApi::ApiBase
    has_one :role, class_name: "FlexCommerce::Role"
  end
end
