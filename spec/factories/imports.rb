FactoryBot.define do
  factory :imports_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/imports/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :import_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/imports/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
