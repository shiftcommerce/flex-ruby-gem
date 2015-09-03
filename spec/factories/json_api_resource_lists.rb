#
# A json-api resource list.  Not used on its own but inherited by
# any list of resources such as products, static pages etc..
#
# This will automatically populate the "data" with a list of factories of type ({#type})
# as well as populating the "links" section with urls etc..  Saves a lot of manual work
# and noise in your specs.
#
# @param [Numeric] quantity (defaults to 1) The quantity of resources to be reported by the list
# @param [Numeric] page_size (defaults to 25) The number of resources to be returned at one time
# @param [Numeric] page (defaults to 1) The page number to return
# @param [String] base_path (defaults to "/test_account/v1") Used as the base path for urls generated in the result's "links" section
# @param [String|Symbol] type (defaults to "") The type (factory) of resources this will contain
# @param [String|Symbol] primary_key (defaults to "id") The primary key used to generate the URL for an individual resource
FactoryGirl.define do
  factory :json_api_resource_list, parent: :json_api_top_singular_resource do
    meta { { type: pluralized_type, page_count: page_count, total_entries: quantity } }
    links { {} }
    data { [] }
    errors { [] }
    transient do
      quantity 1
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
      list.data = build_list(:json_api_resource, quantity, build_resource: evaluator.type.to_sym, base_path: evaluator.base_path, primary_key: evaluator.primary_key)
      list.links.merge! "self": build(:json_api_resource_link,
                                      href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/#{evaluator.page}.json_api",
                                      meta: { page_number: evaluator.page }
                                     )
      list.links.merge! "first": build(:json_api_resource_link,
                                       href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/1.json_api",
                                       meta: { page_number: 1 }
                                      )
      list.links.merge! "last": build(:json_api_resource_link,
                                      href: "#{evaluator.base_path}/#{evaluator.pluralized_type}/pages/#{evaluator.page_count}.json_api",
                                      meta: { page_number: evaluator.page_count }
                                     )
    end
  end
end
