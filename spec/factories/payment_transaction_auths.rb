FactoryGirl.define do
  factory :payment_transaction_auth_from_fixture, class: JsonStruct do
    obj = JsonStruct.new(JSON.parse(File.read("spec/fixtures/payment_transaction_auths/singular.json")))
    obj.each_pair do |key, value|
      send(key, value)
    end
  end
end