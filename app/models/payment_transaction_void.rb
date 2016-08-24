require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Order Transaction Auth model
  #
  # This model provides access to the flex commerce order transaction auth
  #
  #
  #
  class PaymentTransactionVoid < FlexCommerceApi::ApiBase
    belongs_to :transaction, class_name: "::FlexCommerce::OrderTransaction"

    def self.path(params, *args)
      "orders/#{params[:order_id]}/#{super}"
    end
  end
end