FactoryGirl.define do
  klass = Struct.new(:title, :path, :body_type, :body_content)
  factory :static_page, class: klass do
    title { Faker::Lorem.words(3).join(" ") }
    path { Faker::Lorem.words(3).join("/") }
    body_type { "html" }
    body_content { Faker::Lorem.paragraph }
  end
end
