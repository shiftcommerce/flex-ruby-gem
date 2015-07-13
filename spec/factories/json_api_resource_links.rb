#
# Represents a json-api resource link when the object type is preferred (otherwise the link is just a string)
#
# @param [String] href (defaults to "/test_account/v1/resource_type/pages/1")The url of the link
# @param [Hash] meta (defaults to {}) Any meta data
FactoryGirl.define do
  klass = Struct.new(:href, :meta)
  factory :json_api_resource_link, class: klass do
    href "/test_account/v1/resource_type/pages/1"
    meta { {} }
  end
end
