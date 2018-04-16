FactoryBot.define do
  
  klass = Struct.new(:code, :starts_at, :ends_at, :country, :rate)
  
  factory :tax_code, class: klass do
    sequence(:code) { |n| "Code#{n}suffix" }

    starts_at   {  Time.current }
    ends_at     { 1.days.from_now }
    country     "GB"
    rate        0.1

    trait :with_rate do
      starts_at { Time.current.to_formatted_s(:db) }
      ends_at   { 1.days.from_now.to_formatted_s(:db) }
    end
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
