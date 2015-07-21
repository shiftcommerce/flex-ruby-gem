FactoryGirl.define do
  factory :breadcrumb, class: OpenStruct do
    reference { Faker::Lorem.words(3).join("-") }
    title { Faker::Lorem.words(5).join(" ") }
  end

end