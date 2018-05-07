require "spec_helper"
require "flex_commerce_api"

# The payments address verification service in itself is simply a router
# to the correct address verification service which is provider specific
module FlexCommerce
  module Payments
    describe AddressVerification, speed: :slow, account: true do
      include_context "server context"

      context "paypal" do
        let(:paypal_service_class) { class_double("Payments::PaypalExpress::AddressVerification").as_stubbed_const }

        let!(:paypal_service) do
          instance_double(Payments::PaypalExpress::AddressVerification).tap do |instance|
            expect(paypal_service_class).to receive(:new) do |**args|
              expect(args[:payment_provider].reference).to eq(payment_provider.reference)
              expect(args[:address_verification]).to eq(address_verification)
            end.and_return instance
          end
        end

        let(:address) { build_stubbed(:address) }
        let(:payment_provider) {  FlexCommerce::PaymentProvider.all.select{ |p| p.reference == 'paypal_express' }.first }
        let(:transaction) { build_stubbed(:payment_transaction, payment_gateway_reference: "paypal_express") }
        
        let(:address_verification) { instance_double("Payments::PaypalExpress::PaymentAddressVerification", transaction: transaction, address: address) }
        
        subject { described_class.new(address_verification: address_verification) }
        
        it "should direct to the paypal setup service" do
          expect(paypal_service).to receive(:call)
          subject.call
        end
      end
    end
  end
end
