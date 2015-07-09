FactoryGirl.define do
  klass = Struct.new(:href, :meta)
  factory :resource_link, class: klass do
    href "/test_account/v1/resource_type/pages/1"
    meta { {} }
  end
end
