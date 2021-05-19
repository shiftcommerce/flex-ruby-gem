FactoryBot.define do
  factory :retail_store_list, parent: :json_api_resource_list do
    type { "retail_store" }
  end
end
