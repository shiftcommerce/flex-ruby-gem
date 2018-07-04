require "e2e_spec_helper"

RSpec.describe FlexCommerce::PaypalExpress::GenerateSummary, paypal: true do
  def convert_amount(amt)
    (amt * 100).to_i
  end
  context "without tax" do
    subject { described_class.new(cart: cart) }
    shared_examples_for "a summary from a cart with tax ignored" do
      it "should have the correct subtotal" do
        expect(subject.call).to include subtotal: convert_amount(line_items.sum(&:total))
      end
      it "should have zero tax" do
        expect(subject.call).to include tax: 0
      end
      it "should have zero handling" do
        expect(subject.call).to include handling: 0
      end
      it "should have the correct shipping" do
        expect(subject.call).to include shipping: convert_amount(shipping_total)
      end
    end
    shared_examples_for "paypal items" do
      it "should have the correct items - amount and quantity" do
        expect(paypal_items).to match_array(line_items.map {|li| hash_including(amount: convert_amount(li.unit_price), quantity: li.unit_quantity)})
      end
      it "should have the correct items - description" do
        expect(paypal_items).to match_array(line_items.map {|li| hash_including(description: li.title)})
      end
      it "should have the correct items - tax" do
        expect(paypal_items).to match_array(line_items.map {|li| hash_including(tax: convert_amount(li.tax))})
      end
      it "should have the correct items - number" do
        expect(paypal_items).to match_array(line_items.map {|li| hash_including(number: li.item.sku)})
      end

    end
    shared_examples_for "discounted line items" do
      let(:paypal_items) { subject.call[:items][0...-1] }
      include_examples "paypal items"
      it "should have the last item as special discount item" do
        expect(subject.call).to include(items: array_including(hash_including(amount: convert_amount(BigDecimal.new(0) - cart.total_discount))))
      end
    end
    shared_examples_for "non discounted line items" do
      let(:paypal_items) { subject.call[:items] }
      include_examples "paypal items"
    end
    context "with no shipping" do
      let(:shipping_total) { BigDecimal.new(0) }
      context "with no discounts" do
        let(:cart) { double(:cart, free_shipping: false, line_items: line_items, shipping_total: shipping_total, total: line_items.sum(&:total) + shipping_total, total_discount: line_item_discount * line_items.length) }
        let(:line_item_discount) { BigDecimal.new(0) }
        let(:item) { 5.times.map { |n| double(:variant, sku: "sku_#{n}") } }
        let(:line_items) { 5.times.map { |n| double(:line_item, unit_price: BigDecimal.new(1.67, 12), item: item[n], unit_quantity: 3, total: BigDecimal.new(5.01, 12), title: "Line item #{n}", tax: BigDecimal.new(0)) } }
        
        include_examples "a summary from a cart with tax ignored"
        include_examples "non discounted line items"
      end
      context "with line item discounts" do
        let(:cart) { double(:cart, free_shipping: false, line_items: line_items, shipping_total: shipping_total, total: line_items.sum(&:total) + shipping_total, total_discount: line_item_discount * line_items.length) }
        let(:line_item_discount) { BigDecimal.new(0.79, 12) }
        let(:item) { 5.times.map { |n| double(:variant, sku: "sku_#{n}") } }
        let(:line_items) { 5.times.map { |n| double(:line_item, unit_price: BigDecimal.new(1.67, 12), item: item[n], unit_quantity: 3, total: BigDecimal.new(5.01, 12) - line_item_discount, title: "Line item #{n}", tax: BigDecimal.new(0)) } }
        include_examples "a summary from a cart with tax ignored"
        include_examples "discounted line items"
      end
    end
    context "with shipping" do
      let(:shipping_total) { BigDecimal.new(3.99, 12) }
      context "with no discounts" do
        let(:cart) { double(:cart, free_shipping: false, line_items: line_items, shipping_total: shipping_total, total: line_items.sum(&:total) + shipping_total, total_discount: line_item_discount * line_items.length) }
        let(:line_item_discount) { BigDecimal.new(0) }
        let(:item) { 5.times.map { |n| double(:variant, sku: "sku_#{n}") } }
        let(:line_items) { 5.times.map { |n| double(:line_ttem, unit_price: BigDecimal.new(1.67, 12), item: item[n], unit_quantity: 3, total: BigDecimal.new(5.01, 12), title: "Line item #{n}", tax: BigDecimal.new(0)) } }
        include_examples "a summary from a cart with tax ignored"
        include_examples "non discounted line items"
      end
      context "with line item discounts" do
        let(:cart) { double(:cart, free_shipping: false, line_items: line_items, shipping_total: shipping_total, total: line_items.sum(&:total) + shipping_total, total_discount: line_item_discount * line_items.length) }
        let(:line_item_discount) { BigDecimal.new(0.79, 12) }
        let(:item) { 5.times.map { |n| double(:variant, sku: "sku_#{n}") } }
        let(:line_items) { 5.times.map { |n| double(:line_item, unit_price: BigDecimal.new(1.67, 12), item: item[n], unit_quantity: 3, total: BigDecimal.new(5.01, 12) - line_item_discount, title: "Line item #{n}", tax: BigDecimal.new(0)) } }
        include_examples "a summary from a cart with tax ignored"
        include_examples "discounted line items"
      end
    end
  end
end