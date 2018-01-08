FactoryBot.define do
  factory :payment_provider_list_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/payment_providers/multiple.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end
