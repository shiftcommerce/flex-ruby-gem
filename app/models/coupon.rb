require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Coupon model
  #
  # A coupon can be created with a cart id the path
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  # FlexCommerce::Coupon.create(coupon_code: "coupon1", path: { cart_id: current_cart.id })
  #
  class Coupon < FlexCommerceApi::ApiBase
    belongs_to :cart, class_name: "FlexCommerce::Cart"

  end
end
