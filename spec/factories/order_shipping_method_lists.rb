FactoryGirl.define do
  factory :order_shipping_method_list, parent: :json_api_resource_list do
    type "order_shipping_method"
  end
end
