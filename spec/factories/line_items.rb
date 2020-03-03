FactoryBot.define do
  factory :line_item_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/line_items/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
