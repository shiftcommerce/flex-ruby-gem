require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Order Transaction Settle model
  #
  # This model provides access to the flex commerce payment transaction settle
  #
  #
  #
  class PaymentTransactionSettle < FlexCommerceApi::ApiBase
    belongs_to :transaction, class_name: "::FlexCommerce::OrderTransaction"

    def self.path(params, *args)
      "orders/#{params[:order_id]}/#{super}"
    end
  end
end
