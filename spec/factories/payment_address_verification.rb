FactoryBot.define do
  factory :payment_address_verification, class: JsonStruct do
    email { Faker::Internet.email }
    address { attributes_for(:address) }
  end
end
