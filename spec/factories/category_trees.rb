FactoryGirl.define do
  factory :category_trees_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/category_trees/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :category_tree_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/category_trees/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end