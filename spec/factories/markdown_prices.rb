FactoryBot.define do
  klass = Struct.new(:price, :start_at, :end_at)

  factory :markdown_price, class: klass do
    price     { Faker::Number.decimal(2,2) }
    start_at  { Faker::Date.between(2.days.ago, Date.today) }
    end_at    { Faker::Date.between(2.days.ago, Date.today) }
  end

  factory :markdown_prices_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/markdown_prices/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :markdown_price_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/markdown_prices/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

end
