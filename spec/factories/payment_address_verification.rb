FactoryBot.define do
  klass = Struct.new(:email, :address, :transaction, :errors)
  factory :payment_address_verification, class: klass do
    email { Faker::Internet.email }
    address { attributes_for(:address) }
  end
end
