#
# Used to create a "resource" for a json-api response
#
# A resource is simply an object containing the attributes of the data
# in "attributes" and then the id, type and links are stored also.
#
# As a resource always needs to contain a data object, this factory can generate
# one for you if you add something like :-
#
#   build(:json_api_resource, build_resource: :product)
#
#   # Or if you want to specify some attributes for each product :-
#
#   build(:json_api_resource, build_resource: {product: { variant_count: 10 }})
#
# @param [Hash|Symbol|String] build_resource (Defaults to nil) If specified, the factory will populate the attributes
#   from the specified factory or if a hash is given, the key specifies the factory and the value the attributes
#   to be passed to the factory.
# @param [String] base_path (defaults to "/test_account/v1") The base path to build the "self" link
# @param [String|Symbol] primary_key (defaults to "id") The primary key to be used in the generation of the "self" link
# @param [Numeric] id (defaults to the next value) If specified, overrides the default value of the next sequence
# @param [String] type (defaults to "Unknown") If specified and not using {#build_resource}, specifies the type to be returned
# @param [Hash] links (defaults to {}) If specified and not using {#build_resource}, specifies the links to be returned
FactoryGirl.define do
  klass = Struct.new(:id, :type, :attributes, :links, :relationships)
  factory :json_api_resource, class: klass do
    transient do
      build_resource nil
      base_path "/test_account/v1"
      primary_key "id"
    end
    relationships { {} }
    sequence(:id) { |idx| idx.to_s }
    type "Unknown"
    links { {} }
    after(:build) do |ri, evaluator|
      if evaluator.build_resource.present?
        build_resource = evaluator.build_resource
        if build_resource.is_a?(Hash)
          build_options = build_resource[build_resource.keys.first]
          build_resource = build_resource.keys.first
        end
        build_options ||= {}
        ri.attributes = build(build_resource.to_sym, build_options)
        ri.type = build_resource.to_s.pluralize if ri.type == "Unknown"
        item_id = ri.attributes.to_h.merge(id: ri.id, type: ri.type).with_indifferent_access[evaluator.primary_key]
        ri.links = { "self": "#{evaluator.base_path}/#{build_resource.to_s.pluralize}/#{item_id}.json_api" }
      end
    end
  end
end
