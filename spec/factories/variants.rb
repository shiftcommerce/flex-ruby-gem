FactoryBot.define do
  klass = Struct.new(:title, :description, :sku, :price, :reference, :stock_level)
  factory :variant, class: klass do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    sku { Faker::Code.ean }
    reference { Faker::Lorem.words(3).join("-") }
    stock_level { 100 }
  end
end
