require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Promotion model
  #
  # This model provides access to the flex commerce promotion
  #
  class Promotion < FlexCommerceApi::ApiBase
    custom_endpoint :archive, on: :member, request_method: :patch
    custom_endpoint :unarchive, on: :member, request_method: :patch
  end
end
