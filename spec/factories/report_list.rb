FactoryBot.define do
  factory :report_list, parent: :json_api_resource_list do
    type "report"
  end
end
