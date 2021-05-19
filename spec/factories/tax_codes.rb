require "flex_commerce_api"

FactoryBot.define do
  factory :tax_code, class: ::FlexCommerce::TaxCode do
    sequence(:code) { |n| "Code#{n}suffix" }

    starts_at   { Time.current }
    ends_at     { 1.days.from_now }
    country     { "GB" }
    rate        { 0.1 }
  end

  factory :tax_codes_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/tax_codes/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

  factory :tax_code_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/tax_codes/single.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

end
