FactoryBot.define do
  klass = Struct.new(:title, :description, :sku, :price, :reference, :stock_level)
  factory :variant, class: klass do
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    sku { Faker::Code.ean }
    reference { Faker::Lorem.words(3).join("-") }
    stock_level 100
  end

  factory :api_variant, class: ::FlexCommerce::Variant do
    transient do
      product_is_sellable true
    end

    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sku         { Faker::Internet.slug(nil, rand(999).to_s)  }
    reference   { Faker::Internet.slug(nil, rand(999).to_s) }
    price       { Faker::Commerce.price(0.01..100.00) }
    price_includes_taxes true
    tax_code    "VAT"
    stock_level { Faker::Number.number(3).to_i + 250 }
    stock_allocated_level  { Faker::Number.number(2).to_i + 10 }
    sequence(:position) { |n| n }
    product { build(:product, sellable: product_is_sellable) }
    ordered_total { Faker::Number.number(6).to_i + 250 }
    ewis_eligible false
    expected_availability_date { 1.days.from_now }
  end
end
