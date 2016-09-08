require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Product asset file model
  #
  # This model provides access to the flex commerce product asset files.
  #
  #
  class ProductAssetFile < FlexCommerceApi::ApiBase
    belongs_to :product, class_name: "FlexCommerce::Product"
  end
end
