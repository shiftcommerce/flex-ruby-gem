FactoryGirl.define do
  factory :categories_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/categories/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :category_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/categories/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end