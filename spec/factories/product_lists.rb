FactoryBot.define do
  factory :product_list, parent: :json_api_resource_list do
    type "product"
    primary_key "slug"
    after(:build) do |instance|
      instance.data.each do |ri|
        ri.relationships.merge(variants: {data: []})
      end
    end
  end
  factory :product_list_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/products/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
