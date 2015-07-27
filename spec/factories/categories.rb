FactoryGirl.define do
  factory :categories_from_fixture, class: OpenStruct do
    obj = RecursiveOpenStruct.new(JSON.parse(File.read("spec/fixtures/categories/multiple.json")), recurse_over_arrays: true)
    obj.each_pair do |key, _|
      send(key, obj.send(key))
    end
  end
  factory :category_from_fixture, class: OpenStruct do
    obj = RecursiveOpenStruct.new(JSON.parse(File.read("spec/fixtures/categories/singular.json")), recurse_over_arrays: true)
    obj.each_pair do |key, _|
      send(key, obj.send(key))
    end
  end
end