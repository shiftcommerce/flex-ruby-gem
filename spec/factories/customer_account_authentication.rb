FactoryBot.define do
  factory :customer_account_authentication, class: JsonStruct do
    email { Faker::Internet.email }
    sequence(:reference) { |num| "#{Faker::Name.first_name}#{num}" }
    password { "anyoldpassword" }
  end
end
