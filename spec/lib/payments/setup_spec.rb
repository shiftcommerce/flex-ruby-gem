require "spec_helper"
require "flex_commerce_api"

# The payments setup service in itself is simply a router
# to the correct setup service which is provider specific
module FlexCommerce
  module Payments
    describe Setup do
      context "paypal" do

        let(:payment_provider) { instance_double(::FlexCommerce::PaymentProvider, test_mode: false, name: "Paypal Express", reference: "anything", service: "paypal_express") }
        
        before do
          stub_request(:get, "http://testaccount:somerandomkeythatisprettylongevenlongerthanthat@test.flexcommerce.com/testaccount/v1/payment_providers.json_api").
          with(:headers => {'Accept'=>'application/vnd.api+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/vnd.api+json', 'User-Agent'=>'Faraday v0.14.0'}).
          to_return(:status => 200, :body => "", :headers => {})
        end

        let(:paypal_service_class) { class_double("Payments::PaypalExpress::Setup").as_stubbed_const }
        let!(:payment_provider_setup) { PaymentProviderSetup.new  }
        
        let!(:paypal_service) do
          instance_double("Payments::PaypalExpress::Setup").tap do |instance|
            expect(paypal_service_class).to receive(:new).with(cart: cart, payment_provider_setup: payment_provider_setup, payment_provider: nil, success_url: success_url, cancel_url: cancel_url, ip_address: ip_address, callback_url: callback_url, allow_shipping_change: true, use_mobile_payments: false).and_return instance
          end
        end
        let(:cart) { build(:cart_from_fixture_with_checkout) }
        let(:success_url) { "http://localhost/success" }
        let(:cancel_url) { "http://localhost/failure" }
        let(:callback_url) { "http://irrelevant.com" }
        let(:ip_address) { "127.0.0.1" }
        subject { described_class.new(payment_provider_id: 'paypal_express', cart: cart, success_url: success_url, cancel_url: cancel_url, ip_address: ip_address, callback_url: callback_url, allow_shipping_change: true, use_mobile_payments: false) }
        it "should direct to the paypal setup service" do
          puts cart.inspect
          puts ip_address.inspect
          puts success_url.inspect
          puts cancel_url.inspect
          expect(paypal_service).to receive(:call)
          subject.call
        end
      end
    end
  end
end
