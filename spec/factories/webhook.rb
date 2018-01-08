FactoryBot.define do
  klass = Struct.new(:title, :event, :request_url, :request_headers)
  factory :webhook, class: klass do
    title { Faker::Lorem.words(3).join(" ") }
    event { "order_created" }
    request_url "https://example.com/bla"
    request_headers ({ "X-Token" => "test" })
  end
end
