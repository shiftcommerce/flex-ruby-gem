FactoryGirl.define do
  klass = Struct.new(:title, :query)
  factory :report, class: klass do
    title { Faker::Lorem.words(3).join(" ") }
    query { Faker::Lorem.sentences(3).join("\n\n") }
  end
end
