require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Refund model
  #
  # This model provides access to the flex commerce refund
  #
  #
  #
  class Refund < FlexCommerceApi::ApiBase
    belongs_to :order

  end
end
