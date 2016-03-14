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

    def self.create(attributes)
      super(attributes.merge(extra_attributes))
    end

    def self.extra_attributes
      extras = {}
      extras.merge!(order_test_mode) if FlexCommerceApi::Config.order_test_mode
      extras
    end

  end

end