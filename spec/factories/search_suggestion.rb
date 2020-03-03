FactoryBot.define do
  factory :search_suggestion, class: JsonStruct do
    suggestions { Faker::Lorem.words(4).join(",") }
  end
end
