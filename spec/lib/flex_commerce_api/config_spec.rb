require "spec_helper"
require "flex_commerce_api/config"

RSpec.describe FlexCommerceApi::Config do
  subject { Class.new(FlexCommerceApi::Config) }

  it "allows an X-Forwarded-For lambda to be set" do
    subject.forwarded_for = -> { "127.0.0.1" }

    expect(subject.forwarded_for.call).to_eq "127.0.0.1"
  end
end
