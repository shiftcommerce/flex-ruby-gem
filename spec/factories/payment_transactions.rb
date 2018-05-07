require "securerandom"

FactoryBot.define do
  klass = Struct.new(:id, :status, :transaction_type, :currency, :amount, :gateway_response, :payment_gateway_reference, :identity_hash, :container, :container_id)
  factory :payment_transaction, class: klass do
    status "success"
    transaction_type "authorisation"
    currency "GBP"
    amount Faker::Commerce.price(0.01..100.00)
    gateway_response { { "foo": SecureRandom.uuid } }
    payment_gateway_reference "paypal_express"
    identity_hash { SecureRandom.uuid }
    association :container, factory: :cart
  end

end
