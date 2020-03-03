FactoryBot.define do
  klass = Struct.new(:title)
  factory :menu_item, class: klass do
    title { Faker::Lorem.sentence }
    association :menu
  end
  factory :menu_items_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/menu_items/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :menu_item_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/menu_items/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
