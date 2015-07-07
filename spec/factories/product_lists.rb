FactoryGirl.define do
  klass = Struct.new(
      :data,
      :meta,
      :links
  )
  factory :product_list, class: klass do
    meta { { type: "Product", total_pages: 1, total_count: 10 } }
    links { {} }
    data { [] }
    transient do
      quantity 1
    end
    after(:build) do |list, evaluator|
      list.data = build_list(:product, evaluator.quantity)
    end

  end


end