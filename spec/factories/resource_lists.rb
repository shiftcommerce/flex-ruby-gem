FactoryGirl.define do
  klass = Struct.new(:data, :meta, :links, :errors)
  factory :resource_list, class: klass do
    meta { { type: pluralized_type, page_count: page_count, total_entries: quantity } }
    links { {} }
    data { [] }
    errors { [] }
    ignore do
      quantity 1
      sequence(:next_id) { |n| n }
      page_size 25
      page 1
      base_path "/test_account/v1"
      page_count { (quantity / page_size.to_f).ceil.to_i }
      type ""
      pluralized_type { type.to_s.pluralize }
      primary_key "id"
    end
    after(:build) do |list, evaluator|
      quantity = evaluator.quantity % evaluator.page_size
      quantity = evaluator.page_size if quantity == 0
      list.data = build_list(:resource_identifier, quantity, build_resource: evaluator.type.to_sym, base_path: evaluator.base_path, primary_key: evaluator.primary_key)
      list.links.merge! "self": build(:resource_link,
                                      href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/#{evaluator.page}.json",
                                      meta: { page_number: evaluator.page }
                                     )
      list.links.merge! "first": build(:resource_link,
                                       href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/1.json",
                                       meta: { page_number: 1 }
                                      )
      list.links.merge! "last": build(:resource_link,
                                      href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/#{evaluator.page_count}.json",
                                      meta: { page_number: evaluator.page_count }
                                     )
    end
  end
end
