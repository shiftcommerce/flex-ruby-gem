FactoryBot.define do
  klass = Struct.new(:title, :reference, :slug, :latitude, :longitude, :address)
  factory :retail_store, class: klass do
    title { Faker::Lorem.words(3).join(" ") }
    reference { "#{Faker::Number.number(10)}-#{Time.now.nsec}" }
    slug { "#{Faker::Number.number(10)}-#{Time.now.nsec}" }
    latitude { BigDecimal("-1.#{rand(100..998)}") }
    longitude { BigDecimal("53.#{rand(100..998)}") }
    address "Great George St,\nLeeds,\nLS1 3BB"
  end
end
