FactoryBot.define do
  factory :stock_level_list, parent: :json_api_resource_list do
    type { "stock_level" }
  end
end
