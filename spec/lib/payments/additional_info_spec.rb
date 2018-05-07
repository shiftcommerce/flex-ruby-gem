require "spec_helper"
require "flex_commerce_api"

# The payments additional info service in itself is simply a router
# to the correct additional info service which is provider specific
module FlexCommerce
  module Payments
    describe AdditionalInfo, speed: :slow do
      include_context "server context"
      context "paypal" do
        
        let(:paypal_service_class) { class_double("Payments::PaypalExpress::AdditionalInfo").as_stubbed_const }
        
        let(:payment_provider) {  FlexCommerce::PaymentProvider.all.select{ |p| p.reference == 'paypal_express' }.first }
        
        let!(:paypal_service) do
          instance_double("Payments::PaypalExpress::AdditionalInfo").tap do |instance|
            expected_params = {
              payment_provider: payment_provider, options: { token: "my-token" }
            }
            # Did this explicit matching because payment provider 
            # was not working with normal with arguments
            expect(paypal_service_class).to  receive(:new) do |**args|
              expect(args[:options]).to eq({:token => "my-token" })
              expect(args[:payment_provider].reference).to eq(payment_provider.reference)
            end.and_return instance
          end
        end
        
        subject { described_class.new(payment_provider_id: 'paypal_express', options: {token: "my-token"}) }

        it "should direct to the paypal setup service" do
          expect(paypal_service).to receive(:call)
          subject.call
        end

      end

    end
  end
end
