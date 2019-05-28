require "flex_commerce_api"

FactoryBot.define do
  factory :taxonomy, class: ::FlexCommerce::Taxonomy do
    name          { Faker::Lorem.sentence }
    apply_to_all  { false }
    data_type     { "RetailStore" }
  end

  factory :taxonomy_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/taxonomies/single.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
