FactoryBot.define do
  factory :customer_account, class: JsonStruct do
    email { Faker::Internet.email }
    sequence(:reference) { |num| "#{Faker::Name.first_name}#{num}" }
  end
  factory :customer_account_from_fixture, class: JsonStruct do
    transient do
      api_root { "http://api.dummydomain/v1" }
    end
    after(:build) do |instance, evaluator|
      obj = JsonStruct.new(JSON.parse(JsonErb.render_from_hash(File.read("spec/fixtures/customer_accounts/singular.json.erb"), api_root: evaluator.api_root)))
      obj.each_pair do |key, value|
        instance.send("#{key}=", value)
      end

    end
  end
end