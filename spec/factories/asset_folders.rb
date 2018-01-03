FactoryBot.define do
  klass = Struct.new(:name, :reference)
  factory :asset_folder, class: klass do
    sequence(:name) { |n| "asset folder name-#{n}-#{Time.now.nsec}" }
    reference       { "#{Faker::Code.isbn}-#{Time.now.nsec}" }
  end
end