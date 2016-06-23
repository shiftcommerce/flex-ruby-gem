FactoryGirl.define do
  factory :note_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/notes/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end

  factory :note_list_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/notes/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end