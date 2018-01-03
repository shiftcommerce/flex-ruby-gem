FactoryBot.define do
  klass = Struct.new(:price, :start_at, :end_at)

  factory :markdown_price, class: klass do
    price     { Faker::Number.decimal(2,2) }
    start_at  { Faker::Date.between(2.days.ago, Date.today) }
    end_at    { Faker::Date.between(2.days.ago, Date.today) }
  end

end
