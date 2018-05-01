require "rails_helper"
# The payments address verification service in itself is simply a router
# to the correct address verification service which is provider specific
RSpec.describe Payments::AddressVerification, speed: :slow, account: true do
  context "paypal" do
    let(:paypal_service_class) { class_double(Payments::PaypalExpress::AddressVerification).as_stubbed_const }
    let!(:paypal_service) do
      instance_double(Payments::PaypalExpress::AddressVerification).tap do |instance|
        expect(paypal_service_class).to receive(:new).with(payment_provider: payment_provider, address_verification: address_verification).and_return instance
      end
    end
    let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
    let(:address_verification) { instance_double(::PaymentAddressVerification, transaction: transaction, address: address) }
    let(:address) { build_stubbed(:address) }
    let(:transaction) { build_stubbed(:payment_transaction, payment_gateway_reference: "paypal_express_test") }
    subject { described_class.new(address_verification: address_verification) }
    it "should direct to the paypal setup service" do
      expect(paypal_service).to receive(:call)
      subject.call
    end
  end

end
