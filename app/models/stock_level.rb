require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Stock Level model
  #
  # This model provides access to the flex commerce stock level
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching stock levels for specific skus
  #   FlexCommerce::StockLevel.where(skus: "sku1,sku2,sku3").all
  #
  #
  #
  class StockLevel < FlexCommerceApi::ApiBase
  end
end
