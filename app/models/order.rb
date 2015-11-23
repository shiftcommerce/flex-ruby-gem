require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Order model
  #
  # This model provides access to the flex commerce order
  #
  #
  #
  class Order < FlexCommerceApi::ApiBase
    has_many :transactions, class_name: "::FlexCommerce::OrderTransaction"

  end
end
