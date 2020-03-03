FactoryBot.define do
  factory :coupon, class: JsonStruct do
    sequence(:coupon_code) { |idx| "coupon_#{idx}" }
    name { Faker::Commerce.product_name }
  end
end
