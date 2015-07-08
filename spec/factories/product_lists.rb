FactoryGirl.define do
  klass = Struct.new(
      :data,
      :meta,
      :links
  )
  factory :product_list, class: klass do
    meta { { type: "products", page_count: 1, total_entries: 10 } }
    links { {} }
    data { [] }
    transient do
      quantity 1
      sequence(:next_id) {|n| n }
    end
    after(:build) do |list, evaluator|
      list.data = build_list(:product, evaluator.quantity).map.with_index do |product, idx|
        build(:resource_identifier,
              type: "Product",
              id: evaluator.next_id * evaluator.quantity + idx,
              resource: product
        )
      end
    end

  end


end