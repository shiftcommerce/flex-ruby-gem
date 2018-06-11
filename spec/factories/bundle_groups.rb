FactoryBot.define do
  klass = Struct.new(:name, :sequence)
  factory :bundle_group, class: klass do
    name { Faker::Name.title }
    sequence(:sort) { |n| n }
    association :bundle
  end
  factory :bundle_groups_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/bundle_groups/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :bundle_group_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/bundle_groups/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
