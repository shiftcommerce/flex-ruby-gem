require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Promotion model
  #
  # This model provides access to the flex commerce promotion
  #
  class Promotion < FlexCommerceApi::ApiBase
    # This adds the ability to call archive method on Promotion
    # 
    # @usage FlexCommerce::Promotion.find(<id>).archive
    custom_endpoint :archive, on: :member, request_method: :patch

    # This adds the ability to call unarchive method on Promotion
    # 
    # @usage FlexCommerce::Promotion.find(<id>).unarchive
    custom_endpoint :unarchive, on: :member, request_method: :patch
  end
end
