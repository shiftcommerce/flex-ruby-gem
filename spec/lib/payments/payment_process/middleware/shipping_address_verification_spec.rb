# frozen_string_literal: true
require "spec_helper"
require "flex_commerce_api"
module FlexCommerce
  module Payments
    module PaymentProcess
      module Middleware
        describe ShippingAddressVerification do
          include_context "server context"

          let!(:address_verification_service_class) { class_double("Payments::AddressVerification").as_stubbed_const }
          let(:address_verification_service) { instance_double(::Payments::AddressVerification) }
          let(:important_address_attributes) { %w(address_line_1 address_line_2 address_line_3 city state postcode country first_name middle_names last_name) }

          context "#call", account: true do
            context "happy path" do
              let!(:payment_provider) { build_stubbed(:payment_provider, :paypal_express, reference: "paypal_express_test") }
              let(:address) { build(:address_data_from_fixture) }
              let(:cart) { build_stubbed(:cart, :with_line_items, line_items_count: 2, shipping_address: address) }
              let(:transaction) { build(:payment_transaction, container: cart) }
              let(:state) { OpenStruct.new(transaction: transaction) }
              let(:payment_process) do
                build_stubbed :payment_process, cart_id: cart.id,
                                                payment_gateway_reference: "paypal_express_test",
                                                payment_gateway_response: { anything: :goes }
              end

              subject { described_class.new(payment_process: payment_process, state: state) }

              it "should verify the address using the correct service" do
                expect(address_verification_service_class).to receive(:new) do |address_verification:|
                  expect(address_verification).to be_a(PaymentAddressVerification)
                  expect(address_verification).to have_attributes(address.attributes.slice(important_address_attributes))
                  address_verification_service
                end
                expect(address_verification_service).to receive(:call).and_return true
                subject.call
                expect(state.status.to_s).to eql("shipping_address_verification")
                expect(state.message.to_s).to eql("shipping_address_verification")
              end
            end
          end
        end
      end
    end
  end
end
