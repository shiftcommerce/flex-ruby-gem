FactoryBot.define do
  klass = Struct.new(:reference, :title)
  factory :breadcrumb, class: klass do
    reference { Faker::Lorem.words(3).join("-") }
    title { Faker::Lorem.words(5).join(" ") }
  end

end