require "rails_helper"
# The payments additional info service in itself is simply a router
# to the correct additional info service which is provider specific
RSpec.describe Payments::AdditionalInfo, speed: :slow do
  context "paypal" do
    let(:paypal_service_class) { class_double(Payments::PaypalExpress::AdditionalInfo).as_stubbed_const }
    let(:payment_provider) { build_stubbed(:payment_provider, :paypal_express, reference: "paypal_express_test") }
    let!(:paypal_service) do
      instance_double(Payments::PaypalExpress::AdditionalInfo).tap do |instance|
        expect(paypal_service_class).to receive(:new).with(payment_provider: payment_provider, options: { token: "my-token" }).and_return instance
      end
    end
    subject { described_class.new(payment_provider: payment_provider, options: {token: "my-token"}) }
    it "should direct to the paypal setup service" do
      expect(paypal_service).to receive(:call)
      subject.call
    end
  end

end
