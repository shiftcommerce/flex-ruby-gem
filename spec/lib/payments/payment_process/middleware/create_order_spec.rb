# frozen_string_literal: true
# require "rails_helper"
RSpec.describe FlexCommerce::Payments::PaymentProcess::Middleware::CreateOrder, speed: :slow do
  let(:state) { OpenStruct.new }
  context "#call", account: true, use_transactions: true do
    context "normal flow" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:address) { create(:address) }
      let(:shipping_method) { create(:shipping_method) }
      let(:cart) { create(:cart, :with_line_items, line_items_count: 2, billing_address: address, shipping_address: address, shipping_method: shipping_method, email: "test@test.com", payment_transactions: [build(:payment_transaction)]) }
      let(:payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { anything: :goes }
      end

      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should convert the cart to an order" do
        subject.call
        expect(payment_process.order).to be_a(Order)
        expect(state.order).to be_a(Order)
        expect(payment_process.order).to be state.order
        expect(state.status.to_s).to eql("order_created")
        expect(state.message.to_s).to eql("order_created")
      end
    end

    context "calling twice for same cart" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:second_state) { OpenStruct.new }
      let(:address) { create(:address) }
      let(:shipping_method) { create(:shipping_method) }
      let(:cart) { create(:cart, :with_line_items, line_items_count: 2, billing_address: address, shipping_address: address, shipping_method: shipping_method, email: "test@test.com", payment_transactions: [build(:payment_transaction)]) }
      let(:payment_process) do
        build :payment_process, cart_id: cart.id,
                                payment_gateway_reference: "paypal_express_test",
                                payment_gateway_response: { anything: :goes }
      end

      let(:second_subject) { described_class.new(payment_process: ::PaymentProcess.find(payment_process.id), state: second_state) }
      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should not create a new order but find existing one" do
        subject.call
        payment_process.order.save!
        second_subject.call
        expect(second_state.order.id).to eql state.order.id
      end
    end

    context "with missing addresses in cart" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:shipping_method) { create(:shipping_method) }
      let(:cart) { create(:cart, :with_line_items, line_items_count: 2, shipping_method: shipping_method, email: "test@test.com", payment_transactions: [build(:payment_transaction)]) }
      let(:payment_process) do
        build_stubbed :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { anything: :goes }
      end

      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should report the exception if the order cannot be validated" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
        expect(payment_process.order).to be_a(Order)
      end
    end
  end
end
