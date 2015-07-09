FactoryGirl.define do
  klass = Struct.new(:id, :type, :attributes)
  factory :resource_identifier, class: klass do
    transient do
      resource nil
    end
    after(:build) do |ri, evaluator|
      ri.attributes = evaluator.resource
    end
  end
end
