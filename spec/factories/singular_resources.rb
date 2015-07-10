klass = Struct.new(:data, :meta, :errors, :links)
FactoryGirl.define do
  factory :singular_resource, class: klass do
    meta { {} }
    errors []
    links { {} }
  end
end
