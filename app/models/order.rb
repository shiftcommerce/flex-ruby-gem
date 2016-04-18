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
    has_one :shipping_address, class_name: "::FlexCommerce::Address"
    has_one :billing_address, class_name: "::FlexCommerce::Address"

    def self.find_by_customer_account_id(order_id, customer_account_id)
      requestor.send(:request, :get, "customer_accounts/%d/orders/%d" % [customer_account_id, order_id], {})
    end

    def self.all_by_customer_account_id(customer_account_id)
      requestor.send(:request, :get, "customer_accounts/%d/orders" % customer_account_id, {})
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

end
