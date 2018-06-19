FactoryBot.define do
  factory :import_entries_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/import_entries/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
  factory :import_entry_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/import_entries/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
