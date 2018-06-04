require "flex_commerce_api"

FactoryBot.define do
  factory :cart, class: JsonStruct do
    transient do
      line_items_count 3  # number of line items to create in traits
      line_item_unit_quantity 1
    end

    trait :with_line_items do
      after(:create) do |cart, evaluator|
        evaluator.line_items_count.times do
          variant = create(:variant)
          create(:line_item, :cart_variant, container_id: cart.id,
                 item_id: variant.id, item_type: variant.class.to_s, unit_quantity: evaluator.line_item_unit_quantity)
        end
      end
    end
  end

  factory :cart_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/carts/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :cart_from_fixture_with_checkout, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/carts/singular_with_checkout.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :cart_to_merge_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/carts/merge_from_singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :cart_merged_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/carts/merged.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end