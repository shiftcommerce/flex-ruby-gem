require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce discount summary model
  #
  # This model is used by the Cart model as an association so is not
  # usable directly on the API as there is no corresponding URL
  #
  #
  class FreeShippingPromotion < FlexCommerceApi::ApiBase
  end
end
