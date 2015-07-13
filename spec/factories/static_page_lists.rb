FactoryGirl.define do
  factory :static_page_list, parent: :json_api_resource_list do
    type "static_page"
  end
end
