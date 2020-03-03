FactoryBot.define do
  factory :shipping_method, class: JsonStruct do
    sequence(:label) { |idx| "Shipping Method #{idx}" }
    sequence(:price) { |idx| idx * 1.50 }
    sequence(:reference) { |idx| "shipping_method_#{idx}" }
    sequence(:description) { |idx| "Shipping Method #{idx}" }
    tax 1.00
  end
end
