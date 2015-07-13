FactoryGirl.define do
  factory :product_list, parent: :json_api_resource_list do
    type "product"
    primary_key "slug"
  end
end
