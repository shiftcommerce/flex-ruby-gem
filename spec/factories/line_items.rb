require "flex_commerce_api"

FactoryBot.define do
  factory :line_item_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/line_items/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

  factory :api_line_item, class: ::FlexCommerce::LineItem do
    unit_quantity 1

    after(:create) {|line_item| line_item.container.line_items.reset }
  end
end