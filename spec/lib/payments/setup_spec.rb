require "spec_helper"
require "flex_commerce_api"

# The payments setup service in itself is simply a router
# to the correct setup service which is provider specific
module FlexCommerce
  module Payments
    describe Setup, vcr: true, paypal: true do
      include_context "server context"
      context "paypal" do

        let(:payment_provider) {  FlexCommerce::PaymentProvider.all.select{ |p| p.reference == 'paypal_express' }.first }
        
        let(:paypal_service_class) { class_double("FlexCommerce::Payments::PaypalExpress::Setup").as_stubbed_const }
        let!(:payment_provider_setup) { PaymentProviderSetup.new  }
        
        let(:cart) { build(:cart_from_fixture_with_checkout) }
        let(:success_url) { "http://localhost/success" }
        let(:cancel_url) { "http://localhost/failure" }
        let(:callback_url) { "http://irrelevant.com" }
        let(:ip_address) { "127.0.0.1" }
        let(:use_mobile_payments) { false }
        let(:allow_shipping_change) { true }


        let!(:paypal_service) do
          instance_double("FlexCommerce::Payments::PaypalExpress::Setup").tap do |instance|
            expect(paypal_service_class).to receive(:new) do |paypal_service|
              expect(paypal_service[:cart]).to eq(cart)
              expect(paypal_service[:payment_provider_setup].type).to eq(payment_provider_setup.type)
              expect(paypal_service[:payment_provider].reference).to eq(payment_provider.reference)
              expect(paypal_service[:success_url]).to eq(success_url)
              expect(paypal_service[:cancel_url]).to eq(cancel_url)
              expect(paypal_service[:ip_address]).to eq(ip_address)
              expect(paypal_service[:callback_url]).to eq(callback_url)
              expect(paypal_service[:allow_shipping_change]).to eq(allow_shipping_change)
              expect(paypal_service[:use_mobile_payments]).to eq(use_mobile_payments)
            end.and_return instance
          end
        end
        
        subject { described_class.new(
          cart: cart,
          payment_provider_id: 'paypal_express',
          success_url: success_url,
          ip_address: ip_address,
          cancel_url: cancel_url,
          callback_url: callback_url,
          allow_shipping_change: allow_shipping_change,
          use_mobile_payments: use_mobile_payments)
        }
        
        it "should direct to the paypal setup service" do
          expect(paypal_service).to receive(:call)
          subject.call
        end
      end
    end
  end
end
