require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Bundle Group model
  #
  # This model provides access to the flex commerce bundle group
  #
  # It is generally used as a relationship of products rather than by itself
  #
  #
  class BundleGroup < FlexCommerceApi::ApiBase
    belongs_to :bundle, class_name: "::FlexCommerce::Bundle"
    has_many :products, class_name: "::FlexCommerce::Product"
  end
end
