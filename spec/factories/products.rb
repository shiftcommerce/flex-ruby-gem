FactoryGirl.define do
  klass = Struct.new(
      :title
  )
  factory :product, class: klass do
    title { Faker::Commerce.product_name }
  end
end