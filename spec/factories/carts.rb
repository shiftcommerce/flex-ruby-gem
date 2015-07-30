FactoryGirl.define do
  factory :cart_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/carts/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end