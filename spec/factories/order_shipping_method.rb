FactoryGirl.define do
  factory :order_shipping_method, class: JsonStruct do
    sequence(:label) { |idx| "Shipping Method #{idx}" }
    sequence(:price) { |idx| idx * 1.50 }
    tax 1.00
  end
end