#
# Represents a singular json-api resource
#
# @param [Hash] data The data to be returned (a single item not an array)
# @param [Hash] meta (defaults to {}) The meta to be returned
# @param [Hash[]] errors A list of error objects to be returned
# @param [Hash] links An object containing the links to be returned
FactoryGirl.define do
  klass = Struct.new(:data, :meta, :errors, :links, :included)
  factory :json_api_top_singular_resource, class: klass do
    meta { {} }
    errors []
    links { {} }
    included { [] }
  end
end
