FactoryGirl.define do
  klass = Struct.new(:data, :meta, :links)
  factory :product_list, class: klass do
    meta { { type: "products", page_count: page_count, total_entries: quantity } }
    links { {} }
    data { [] }
    transient do
      quantity 1
      sequence(:next_id) { |n| n }
      page_size 25
      page 1
      base_path "/test_account/v1"
      page_count { (quantity / page_size.to_f).ceil.to_i }
    end
    after(:build) do |list, evaluator|
      quantity = evaluator.quantity % evaluator.page_size
      quantity = evaluator.page_size if quantity == 0
      list.data = build_list(:product, quantity).map.with_index do |product, idx|
        build(:resource_identifier,
              type: "Product",
              id: evaluator.next_id * quantity + idx,
              resource: product
             )
      end
      list.links.merge! "self": build(:resource_link,
                                      href: "#{evaluator.base_path}/#{list.meta[:type]}/pages/#{evaluator.page}.json",
                                      meta: { page_number: evaluator.page }
                                     )
      list.links.merge! "first": build(:resource_link,
                                       href: "#{evaluator.base_path}/#{list.meta[:type]}/pages/1.json",
                                       meta: { page_number: 1 }
                                      )
      list.links.merge! "last": build(:resource_link,
                                      href: "#{evaluator.base_path}/#{list.meta[:type]}/pages/#{evaluator.page_count}.json",
                                      meta: { page_number: evaluator.page_count }
                                     )
    end
  end
end
