klass = Struct.new(:data, :meta)
FactoryGirl.define do
  factory :singular_resource, class: klass do
    meta { {} }
  end
end
