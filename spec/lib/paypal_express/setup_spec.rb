require "e2e_spec_helper"

# The payments setup service for paypal express
RSpec.describe FlexCommerce::PaypalExpress::Setup, vcr: true, paypal: true do
  include_context "context store"
  include_context "housekeeping"

  context "paypal" do

     # Mock active merchant
    let(:active_merchant_gateway_class) { class_double("ActiveMerchant::Billing::PaypalExpressGateway").as_stubbed_const }
    let(:active_merchant_gateway) { instance_spy("ActiveMerchant::Billing::PaypalExpressGateway") }

    # Inputs to the service
    let(:success_url) { "http://success.com" }
    let(:cancel_url) { "http://failure.com" }
    let(:callback_url) { "http://irrelevant.com" }
    let(:ip_address) { "127.0.0.1" }
    let(:use_mobile_payments)  { false }
    let(:allow_shipping_change) { true }

    # Prepare cart data
    API_CART_INCLUDES = [
      "line_items.item",
      "line_items.item.product",
      "discount_summaries",
      "shipping_method",
      "shipping_address",
      "billing_address",
      "available_shipping_promotions.shipping_methods"
    ].join(',').freeze

    let(:uuid) { SecureRandom.uuid }

    let(:global_product) do
      to_clean.global_product ||= FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                                                reference: "reference for product 1 for variant #{uuid}",
                                                                content_type: "markdown").freeze
    end

    let(:global_variant) do
      to_clean.global_variant ||= FlexCommerce::Variant.create(title: "Title for Test Variant #{uuid}",
        description: "Description for Test Variant #{uuid}",
        reference: "reference_for_test_variant_#{uuid}",
        price: 5.50,
        price_includes_taxes: false,
        sku: "sku_for_test_variant_#{uuid}",
        product_id: global_product.id).freeze
    end

    let(:cart_id) do
      FlexCommerce::Cart.create.id
    end

    let(:line_items) do
      to_clean.line_items ||= FlexCommerce::LineItem.create(item_id: global_variant.id, unit_quantity: 2, item_type: 'Variant', cart_id: cart_id)
    end

    let(:shipping_address) do
      to_clean.shipping_address ||= FlexCommerce::Address.create(first_name: 'First Name', last_name: 'Last name', address_line_1: 'Address line 1', city: 'Leeds', country: 'GB', postcode: 'LS10 1QN')
    end

    subject { described_class.new(cart: cart, success_url: success_url, cancel_url: cancel_url, ip_address: ip_address, callback_url: callback_url, allow_shipping_change: allow_shipping_change, use_mobile_payments: use_mobile_payments) }

    context "normal flow" do

      let(:redirect_url) { "https://some.paypal.url.com" }
      let(:paypal_token) { "paypal_token" }
      let(:positive_paypal_response) { instance_double("ActiveMerchant::Billing::PaypalExpressResponse", success?: true, token: paypal_token) }


      shared_examples_for "any paypal setup" do

        it "should communicate with the paypal gem and on success set redirect_url on the setup" do
          expect(active_merchant_gateway).to receive(:setup_order).and_return positive_paypal_response
          expect(active_merchant_gateway).to receive(:redirect_url_for).with(paypal_token, { mobile: use_mobile_payments }).and_return redirect_url
          response = subject.call
          expect(response.errors).to be_nil
          expect(response.redirect_url).to eq(redirect_url)
        end

        it "should set the setup_type to redirect" do
          expect(active_merchant_gateway).to receive(:setup_order).and_return positive_paypal_response
          expect(active_merchant_gateway).to receive(:redirect_url_for).with(paypal_token, { mobile: use_mobile_payments }).and_return redirect_url
          response = subject.call
          expect(response.errors).to be_nil
          expect(response.setup_type).to eq("redirect")
        end

        it "should have the correct items" do
          expected_items = cart.line_items.map do |li|
            hash_including name: li.title,
                           number: li.item.sku,
                           quantity: li.unit_quantity,
                           amount: ((li.total / li.unit_quantity) * 100).round.to_i,
                           description: li.title

          end

          expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            expect(total).to eql((cart.total * 100).round.to_i)
            expect(params[:items]).to match_array(expected_items)
            positive_paypal_response
          end

          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should send a total which matches the sum of the line items" do
            expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            handling = params.fetch(:handling, 0)
            shipping = params.fetch(:shipping, 0)
            tax = params.fetch(:tax, 0)
            items_total = params[:items].sum { |li| li[:amount] * li[:quantity] }
            expect(total).to eql items_total + shipping + tax + handling
            positive_paypal_response
          end
          subject.call
        end

        it "should have the correct currency" do
          expect(active_merchant_gateway).to receive(:setup_order).with(kind_of(Integer), hash_including(currency: "GBP")).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the correct total" do
          expect(active_merchant_gateway).to receive(:setup_order).with((cart.total * 100).round.to_i, hash_including(currency: "GBP")).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the correct subtotal" do
          expect(active_merchant_gateway).to receive(:setup_order) do |*params|
            expect(params[0]).to eq((cart.total * 100).round.to_i)
            expect(params[1][:currency]).to eq("GBP")
            expect(params[1][:subtotal]).to eq(((cart.total - cart.tax - cart.shipping_total) * 100).round.to_i)
          end.and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the correct shipping" do
          expect(active_merchant_gateway).to receive(:setup_order) do |*params|
            expect(params[0]).to eq((cart.total * 100).round.to_i)
            expect(params[1][:currency]).to eq("GBP")
            expect(params[1][:shipping]).to eq((cart.shipping_total * 100).round.to_i)
          end.and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the shipping options set with the default equal to the shipping unless the shipping is zero" do
          expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            expect(params[:shipping_options].select {|so| so[:default]}).to contain_exactly(hash_including(amount: params[:shipping]))
            positive_paypal_response
          end
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the shipping options with at least 1 default when the callback is used" do
          expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            next unless params.key?(:callback_url)
            default_shipping = params[:shipping_options].select {|so| so[:default]}
            expect(default_shipping).to be_present
            positive_paypal_response
          end
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the correct tax" do
          expect(active_merchant_gateway).to receive(:setup_order).with((cart.total * 100).round.to_i, hash_including(currency: "GBP", tax: (cart.tax * 100).round.to_i)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have zero handling" do
          expect(active_merchant_gateway).to receive(:setup_order).with((cart.total * 100).round.to_i, hash_including(currency: "GBP", handling: 0)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have its total equal to the sum of subtotal, shipping, tax and handling" do
          expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            expect(total).to eql((cart.total * 100).round.to_i)
            error_msg = "Mismatch in totals - cart.total is #{cart.total} - params are #{params.slice(:subtotal, :ahipping, :tax, :handling).to_json} variant prices are #{cart.line_items.map {|li| li.item.price.to_s}}, line item prices are #{cart.line_items.to_a.map {|li| li.total.to_s}}, total discount is #{cart.total_discount}, shipping_total is #{cart.shipping_total}"
            expect(total).to eql(params[:subtotal] + params[:shipping] + params[:tax] + params[:handling]), error_msg
            positive_paypal_response
          end
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the return_url" do
          expect(active_merchant_gateway).to receive(:setup_order).with(kind_of(Integer), hash_including(return_url: success_url)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the cancel_return_url" do
          expect(active_merchant_gateway).to receive(:setup_order).with(kind_of(Integer), hash_including(cancel_return_url: cancel_url)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end

        it "should have the ip" do
          expect(active_merchant_gateway).to receive(:setup_order).with(kind_of(Integer), hash_including(ip: ip_address)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end
      end

      shared_examples_for "a paypal setup with shipping address" do
        it "should have the shipping address in the paypal params" do
          shipping_address_paypal_params = {
            address_override: true,
            shipping_address: {
              name: "#{shipping_address.first_name} #{shipping_address.middle_names} #{shipping_address.last_name}",
              address1: shipping_address.address_line_1,
              address2: "#{shipping_address.address_line_2} #{shipping_address.address_line_3}",
              city: shipping_address.city,
              state: shipping_address.state,
              country: shipping_address.country,
              zip: shipping_address.postcode
            }
          }
          expect(active_merchant_gateway).to receive(:setup_order).with(kind_of(Integer), hash_including(shipping_address_paypal_params)).and_return positive_paypal_response
          response = subject.call
          expect(response.errors).to be_nil
        end
      end

      shared_examples_for "a paypal setup that does not allow shipping change" do
        let(:allow_shipping_change) { false }
        it "should not have the shipping options" do
          expect(active_merchant_gateway).to receive(:setup_order) do |total, params|
            expect(params[:shipping_options]).to eq([])
            positive_paypal_response
          end
          response = subject.call
          expect(response.errors).to be_nil
        end
      end

      context "in test mode" do
        before(:each) do
          expect(active_merchant_gateway_class).to receive(:new).with(test: true, login: ENV['PAYPAL_LOGIN'], password: ENV['PAYPAL_PASSWORD'], signature: ENV['PAYPAL_SIGNATURE']).and_return active_merchant_gateway
        end
        context "with a cart ready for checkout standard" do
          let(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end
          let(:cart) do
            cart ||= FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id, shipping_address_id: shipping_address.id)
            cart
          end
          it_should_behave_like "any paypal setup"
          it_should_behave_like "a paypal setup with shipping address"
        end

        context "with a cart that has rounding error" do
          let(:cart) do
            FlexCommerce::Cart.find(line_items.container_id) do |cart|
              new_total = cart.total - 0.0000000000000001
              allow(cart).to receive(:total).and_return(new_total)
            end
          end

          it_should_behave_like "any paypal setup"
        end

        context "with a cart ready for 'Click & Collect' checkout" do
          let!(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end
          let(:cart) do
            cart = FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id)
            cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
            cart
          end
          it_should_behave_like "a paypal setup that does not allow shipping change"
        end

        context "with a cart ready for mobile checkout" do
          let!(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end
          let(:cart) do
            cart = FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id, shipping_address_id: shipping_address.id)
            cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
            cart
          end
          let(:use_mobile_payments) { true }
          it_should_behave_like "any paypal setup"
          it_should_behave_like "a paypal setup with shipping address"
        end
      end

      context "in production mode" do
        before(:each) do
          allow_any_instance_of(FlexCommerce::PaypalExpress::Api).to receive(:test_mode).and_return(false)
          expect(active_merchant_gateway_class).to receive(:new).with(test: false, login: ENV['PAYPAL_LOGIN'], password: ENV['PAYPAL_PASSWORD'], signature: ENV['PAYPAL_SIGNATURE']).and_return active_merchant_gateway
        end
        context "with a cart ready for checkout standard" do
          let!(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end
          let(:cart) do
            cart = FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id, shipping_address_id: shipping_address.id)
            cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
            cart
          end
          it_should_behave_like "any paypal setup"
          it_should_behave_like "a paypal setup with shipping address"
        end

        context "with a cart ready for 'Click & Collect' checkout" do
          let!(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end

          let(:cart) do
            cart = FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id)
            cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
            cart
          end
          it_should_behave_like "a paypal setup that does not allow shipping change"
        end

        context "with a cart ready for mobile checkout" do
          let!(:shipping_method) do
            to_clean.shipping_method ||= FlexCommerce::ShippingMethod.create(reference:"testing_shipping_#{uuid}", sku: "test_shipping_#{uuid}", label: 'Test Shipping Method', total: '5.00')
          end

          let(:cart) do
            cart = FlexCommerce::Cart.find(line_items.container_id)
            cart.update(shipping_method_id: shipping_method.id, shipping_address_id: shipping_address.id)
            cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
            cart
          end
          let(:use_mobile_payments) { true }
          it_should_behave_like "any paypal setup"
          it_should_behave_like "a paypal setup with shipping address"
        end
      end

    end

    context "unhappy flow" do
      context "with a cart with an invalid shipping_method_id" do
        let(:cart) do
          cart = FlexCommerce::Cart.find(line_items.container_id)
          cart = FlexCommerce::Cart.with_params(version: "#{DateTime.now.strftime('%Q')}#{rand(100)}").includes(API_CART_INCLUDES).find(cart.id).first
          cart.shipping_method_id = -1
          cart
        end
        let(:use_mobile_payments) { true }
        it "should not call active merchant and should mark the cart with an error" do
          expect(active_merchant_gateway_class).not_to receive(:new)
          response = subject.call
          expect(response.errors).not_to be_nil
        end
      end
    end
  end
end
#
# The OrderTotal us the amount that is sent to setup_purchase
# subtotal (ItemTotal), shipping (ShippingTotal), handling (HandlingTotal), and tax (TaxTotal) must all add up to the same figure
