FactoryBot.define do
  klass = Struct.new(:first_name, :last_name, :middle_names, :address_line_1, :address_line_2, :address_line_3, :city, :state, :postcode, :country, :preferred_billing, :preferred_shipping)
  factory :address, class: klass do
    sequence(:first_name) { |n| "#{Faker::Name.first_name}#{n}suffix" }
    sequence(:last_name) { |n| "#{Faker::Name.last_name}#{n}suffix" }
    sequence(:middle_names) { |n| "#{Faker::Name.first_name}#{n}suffix" }
    address_line_1 { Faker::Address.street_name }
    address_line_2 { Faker::Address.street_address }
    address_line_3 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postcode { Faker::Address.postcode }
    country { Faker::Address.country }
    preferred_billing false
    preferred_shipping false
  end
  factory :addresses_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/addresses/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :address_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/addresses/single.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
