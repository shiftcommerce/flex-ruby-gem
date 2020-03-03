FactoryBot.define do
  klass = Struct.new(:name, :starts_at, :active, :priority, :coupon_type, :coupon_code, :promotion_type, :shipping_methods)
  factory :promotion, class: klass do
    name "Promotion name"
    starts_at { 10.days.ago.strftime("%Y-%m-%dT%T") }
    # ends_at             "2015-09-10 12:25:46"
    active true
    priority 1
    coupon_type "none"
    coupon_code ""
    shipping_methods []

    trait :fixed_amount do
      # initialize_with  { Promotion::AmountDiscountOnCartRule.new(attributes) }
      promotion_type "AmountDiscountOnCartRule"
      discount_amount 9.99
    end

    trait :free_shipping do
      # initialize_with { FlexCommerce::Promotion::FactoryBot.build(attributes).object }
      promotion_type "FreeShippingRule"
      after(:build) do |promotion, _|
        promotion.shipping_methods << _.shipping_methods
      end
    end
  end
end
