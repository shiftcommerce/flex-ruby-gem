FactoryGirl.define do
  klass = Struct.new(:token_present, :token_expired)
  factory :password_recovery, class: klass do
    token_present { [true, false].sample}
    token_expired { [true, false].sample}

    factory :password_recovery_with_valid_token do
      token_present true
      token_expired false
    end

    factory :password_recovery_with_used_token do
      token_present false
      token_expired true
    end
  end
end
