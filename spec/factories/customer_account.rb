FactoryGirl.define do
  factory :customer_account, class: JsonStruct do
    email { Faker::Internet.email }
    sequence(:reference) { |num| "#{Faker::Name.first_name}#{num}" }
  end
  factory :customer_account_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/customer_accounts/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end