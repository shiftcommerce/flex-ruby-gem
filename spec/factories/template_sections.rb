FactoryBot.define do
  klass = Struct.new(:label, :reference, :preview_icon)

  factory :template_section, class: klass do
    label       { Faker::Lorem.sentence }
    reference   { Faker::Lorem.characters(5) }
  end

  factory :template_section_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/template_sections/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

  factory :template_sections_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/template_sections/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
