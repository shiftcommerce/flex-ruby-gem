FactoryBot.define do
  factory :cart, class: JsonStruct do
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
