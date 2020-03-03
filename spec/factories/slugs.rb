FactoryBot.define do
  klass = Struct.new(:slug, :resource_id, :resource_type, :active, :slug_prefix, :computed_slug)

  factory :slug, class: klass do
    slug { Faker::Internet.slug }
    resource_id { 1 }
    resource_type { "Product" }
    active { true }
    slug_prefix { "products" }
    computed_slug { [slug_prefix, slug].join("/") }
  end
end
