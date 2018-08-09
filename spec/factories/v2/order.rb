FactoryBot.define do
  factory :v2_order_from_fixture, class: JsonStruct do
    transient do
      api_root "http://api.dummydomain/v2"
    end

    after(:build) do |instance, evaluator|
      obj = JsonStruct.new(JSON.parse(JsonErb.render_from_hash(File.read("spec/fixtures/v2/orders/singular.json.erb"), api_root: evaluator.api_root)))
      obj.each_pair do |key, value|
        instance.send("#{key}=", value)
      end
    end
  end
end
