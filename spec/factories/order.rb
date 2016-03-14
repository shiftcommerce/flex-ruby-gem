FactoryGirl.define do
  factory :order, class: JsonStruct do
    # email { Faker::Internet.email }
    # sequence(:reference) { |num| "#{Faker::Name.first_name}#{num}" }
    # channel "web"
    # status "pending"
    # date Time.now.utc
    # sub_total 10
    # total 11
    # tax 15
    # shipping_total 10
    # total_discount 10
  end

  factory :order_from_fixture, class: JsonStruct do
    transient do
      api_root "http://api.dummydomain/v1"
    end

    after(:build) do |instance, evaluator|
      obj = JsonStruct.new(JSON.parse(JsonErb.render_from_hash(File.read("spec/fixtures/orders/singular.json.erb"), api_root: evaluator.api_root)))
      obj.each_pair do |key, value|
        instance.send("#{key}=", value)
      end
    end
  end

end