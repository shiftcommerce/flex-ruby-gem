FactoryBot.define do
  klass = Struct.new(:id, :name, :service, :reference, :test_mode, :meta_attributes)
  factory :payment_provider, class: klass do
    name "A Payment Provider"
    sequence(:reference) {|n| "payment-provider-#{n}"}
    service "invalid"

    trait :paypal_express do
      name "Paypal Express"
      reference "paypal_express"
      service "paypal_express"
      test_mode true
      meta_attributes do
        {
            login: {key: "login", value: "paypaltest_api1.matalan.co.uk"},
            password: {key: "password", value: "1363186359"},
            signature: {key: "signature", value: "Am4WYlSWX.KqnF0KO.Kb4sNcwVY9ARdbUX3EODQC1WlW-wNrb0gJMDM9"}
        }
      end
    end
  end
end
