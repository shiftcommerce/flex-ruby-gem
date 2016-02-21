FactoryGirl.define do
  klass = Struct.new(:name, :reference, :slug, :description)
  factory :bundle, class: klass do
    name { Faker::Lorem.words(3).join(" ") }
    reference { "#{Faker::Number.number(10)}-#{Time.now.nsec}" }
    slug { "#{Faker::Number.number(10)}-#{Time.now.nsec}" }
    description { Faker::Lorem.sentences(3).join("\n\n") }
  end

  factory :bundle_list, parent: :json_api_resource_list do
    type "bundle"
  end
end
