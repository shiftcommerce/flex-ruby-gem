require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce ContainerCoupon model
  #
  #
  class ContainerCoupon < FlexCommerceApi::ApiBase
    has_one :promotion, class_name: "FlexCommerce::Promotion"
    belongs_to :order, class_name: "FlexCommerce::Order"

  end
end
