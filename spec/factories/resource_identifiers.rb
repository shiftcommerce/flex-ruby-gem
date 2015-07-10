FactoryGirl.define do
  klass = Struct.new(:id, :type, :attributes, :links)
  factory :resource_identifier, class: klass do
    ignore do
      resource nil
      build_resource nil
      base_path "/test_account/v1"
      primary_key "id"
    end
    sequence :id
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
        ri.type = build_resource.to_s.camelize
        item_id = ri.attributes.to_h.merge(id: ri.id, type: ri.type).with_indifferent_access[evaluator.primary_key]
        ri.links = { "self": "#{evaluator.base_path}/#{build_resource.to_s.pluralize}/#{item_id}.json" }
      else
        ri.attributes = evaluator.resource if ri.attributes.nil? && evaluator.resource.present?
      end
    end
  end
end
