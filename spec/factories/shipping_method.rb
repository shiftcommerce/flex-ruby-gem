require "flex_commerce_api"
FactoryBot.define do
  factory :shipping_method, class: JsonStruct do
    sequence(:label) { |idx| "Shipping Method #{idx}" }
    sequence(:price) { |idx| idx * 1.50 }
    sequence(:reference) { |idx| "shipping_method_#{idx}" }
    sequence(:description) { |idx| "Shipping Method #{idx}" }
    tax 1.00
  end

  factory :api_shipping_method, class: ::FlexCommerce::ShippingMethod do
    label { Faker::Lorem.sentence(2) }
    total { Faker::Commerce.price(0.01..100.00) }
    tax_rate { rand.round(2) }
    description { Faker::Lorem.sentence(2) }
    sequence(:reference) { "shipping_method_#{Faker::Number.number(10)}-#{Time.now.nsec}" }

    trait :with_meta do
      after(:create) do |instance|
        instance.meta << Meta.new(key: "business_address", value: Faker::Address.street_address, data_type: "text")
        instance.save!
      end
    end
  end
end