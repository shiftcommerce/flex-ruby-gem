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
    has_many :line_items, class_name: "::FlexCommerce::LineItem"
    has_many :coupons, class_name: "::FlexCommerce::Coupon"
    has_one :shipping_promotion, class_name: "::FlexCommerce::Promotion"
    has_one :shipping_address, class_name: "::FlexCommerce::Address"
    has_one :billing_address, class_name: "::FlexCommerce::Address"

    def self.path(params = nil, record = nil)
      if params && params[:filter] && (customer_id = params[:filter].delete(:customer_account_id))
        File.join("customer_accounts/%d" % customer_id, super)
      else
        super
      end
    end

  end

  def self.create(attributes)
    super(attributes.merge(extra_attributes))
  end

  def self.extra_attributes
    extras = {}
    extras.merge!(test: true) if FlexCommerceApi.config.order_test_mode
    extras
  end
end
