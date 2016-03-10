FactoryGirl.define do
  klass = Struct.new(:name, :starts_at, :active, :priority, :coupon_type, :coupon_code, :promotion_type)
  factory :promotion, class: klass do
    name                "Promotion name"
    starts_at           { 10.days.ago.strftime('%Y-%m-%dT%T') }
    # ends_at             "2015-09-10 12:25:46"
    active              true
    priority            1
    coupon_type         "none"
    coupon_code         ""

    trait :fixed_amount do
      # initialize_with  { Promotion::AmountDiscountOnCartRule.new(attributes) }
      promotion_type   "AmountDiscountOnCartRule"
      discount_amount  9.99
    end

  end
end
