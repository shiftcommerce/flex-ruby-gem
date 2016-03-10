FactoryGirl.define do
  klass = Struct.new(:title, :reference, :category_tree_id)
  factory :category, class: klass do
    title       { Faker::Lorem.sentence }
    reference   { rand(1000000000).to_s }
    category_tree_id "reference:web"
  end
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