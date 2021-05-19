FactoryBot.define do
  factory :webhook_list, parent: :json_api_resource_list do
    type { "webhook" }
  end
end
