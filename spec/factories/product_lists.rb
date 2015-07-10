FactoryGirl.define do
  factory :product_list, parent: :resource_list do
    type "product"
    primary_key "slug"
  end
end
