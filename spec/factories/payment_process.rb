require "flex_commerce_api"

FactoryBot.define do
  klass = Struct.new(:id, :payment_gateway_reference, :cart_id, :payment_gateway_response, :additional_processes, :post_processes, :retry_count, :progress_percent_complete, :progress_i18n_token, :status)
  factory :payment_process, class: klass do
    payment_gateway_reference "paypal-express"
    retry_count 0
    additional_processes []
    post_processes []
  end

  factory :api_payment_process, class: ::FlexCommerce::PaymentProcess do
    payment_gateway_reference "paypal-express"
  end
end
