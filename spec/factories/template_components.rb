FactoryGirl.define do
  klass = Struct.new(:label, :reference, :preview_icon)
  
  factory :template_component, class: klass do
    label       { Faker::Lorem.sentence }
    reference   { Faker::Lorem.characters(5) }
  end
end
