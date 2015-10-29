FactoryGirl.define do
  factory :addresses_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/addresses/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end