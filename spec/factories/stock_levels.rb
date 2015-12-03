FactoryGirl.define do
  klass = Struct.new(:stock_available)
  factory :stock_level, class: klass do
    stock_available { Faker::Number.between(1, 1000).to_i }
  end
end
