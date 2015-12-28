FactoryGirl.define do
  factory :order_transaction_void_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/order_transaction_voids/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end