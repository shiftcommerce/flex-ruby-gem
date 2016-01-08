FactoryGirl.define do
  klass = Struct.new(:title, :description, :reference, :min_price, :max_price, :slug)
  factory :product, class: klass do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.words(10).join(" ") }
    reference { Faker::Internet.slug }
    sequence :min_price
    sequence(:max_price) { |p| p + 0.5 }
    slug { Faker::Internet.slug }
  end
  factory :product_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/products/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
