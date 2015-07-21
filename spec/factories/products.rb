FactoryGirl.define do
  klass = Struct.new(:title, :description, :reference, :min_price, :max_price, :slug, :variants)
  factory :product, class: klass do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.words(10).join(" ") }
    reference { Faker::Internet.slug }
    sequence :min_price
    sequence(:max_price) { |p| p + 0.5 }
    slug { Faker::Internet.slug }
    variants []
    transient do
      variants_count 0
    end
    after(:build) do |item, evaluator|
      item.variants = build_list(:variant, evaluator.variants_count)
    end
  end
  factory :product_from_fixture, class: OpenStruct do
    obj = RecursiveOpenStruct.new(JSON.parse(File.read("spec/fixtures/products/singular.json")), recurse_over_arrays: true)
    obj.each_pair do |key, _|
      send(key, obj.send(key))
    end
  end

end
