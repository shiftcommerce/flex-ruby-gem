FactoryGirl.define do
  factory :shipping_method_list, parent: :json_api_resource_list do
    type "shipping_method"
  end
end
