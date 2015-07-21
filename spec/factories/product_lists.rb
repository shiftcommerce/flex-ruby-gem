FactoryGirl.define do
  factory :product_list, parent: :json_api_resource_list do
    type "product"
    primary_key "slug"
  end
  factory :product_list_from_fixture, class: OpenStruct do
    obj = RecursiveOpenStruct.new(JSON.parse(File.read("spec/fixtures/products/multiple.json")), recurse_over_arrays: true)
    obj.each_pair do |key, _|
      send(key, obj.send(key))
    end
  end
end
