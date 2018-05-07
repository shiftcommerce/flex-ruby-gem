# frozen_string_literal: true
# require "rails_helper"
RSpec.describe Payments::PaymentProcess::Middleware::ApplyPromotions, speed: :slow do
  let(:state) { OpenStruct.new }
  let(:promotions_service) { class_double(Promotions).as_stubbed_const }
  context "#call", account: true, use_transactions: true do
    context "normal flow" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:address) { create(:address) }
      let(:shipping_method) { create(:shipping_method) }
      let(:cart) { create(:cart, :with_line_items, line_items_count: 2, billing_address: address, shipping_address: address, shipping_method: shipping_method, email: "test@test.com", payment_transactions: [build(:payment_transaction)]) }
      let(:payment_process) do
        build_stubbed :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { anything: :goes }
      end

      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should apply the promotions to payment_process" do
        in_memory_cart = payment_process.cart
        expect(promotions_service).to receive(:apply_to_cart).with(cart: in_memory_cart)
        subject.call
        expect(state.status.to_s).to eql("promotions_applied")
        expect(state.message.to_s).to eql("promotions_applied")
      end
    end

    context "when called with cart already converted to an order" do
      let(:address) { create(:address) }
      let(:shipping_method) { create(:shipping_method) }
      let(:order) { create(:order, :with_line_items, line_items_count: 2, billing_address: address, shipping_address: address, shipping_method: shipping_method, email: "test@test.com", payment_transactions: [build(:payment_transaction)]) }
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:payment_process) do
        build_stubbed :payment_process, cart_id: order.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { anything: :goes },
                                        order_id: order.id
      end

      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should do nothing but appear processed if the cart does not exist - it has been converted to an order" do
        subject.call
        expect(state.status.to_s).to eql("promotions_applied")
        expect(state.message.to_s).to eql("promotions_applied")
      end
    end
  end
end
