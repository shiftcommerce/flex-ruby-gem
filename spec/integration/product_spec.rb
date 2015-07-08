require "spec_helper"
require "flex_commerce_api"
require "flex_commerce_api/product"
require "uri"
RSpec.describe FlexCommerceApi::Product do
  include_context "global context"
  let(:quantity) { 0 }
  let(:product_list) { build(:product_list, quantity: quantity) }
  let(:subject_class) { subject.class }
  context "with a small data set" do
    let(:quantity) { 10 }
    before :each do
      stub_request(:get, "#{api_root}/products").with(headers: { 'Accept'=>'application/vnd.api+json' }).to_return body: product_list.to_json, status: 200, headers: default_headers
    end
    it "should return a number of instances when the all class method is called" do
      subject_class.all.tap do |list|
        expect(list.total_entries).to eql quantity
        expect(list.total_pages).to eql 1
        expect(list.current_page).to eql 1
        expect(list.count).to eql quantity
        list.each_with_index do |p, idx|
          expect(p).to be_a subject_class
          product_list.data[idx].tap do |resource_identifier|
            resource_identifier.attributes.tap do |mock|
              expect(p.title).to eql mock.title
              expect(p.description).to eql mock.description
              expect(p.reference).to eql mock.reference
              expect(p.min_price).to eql mock.min_price
              expect(p.max_price).to eql mock.max_price
              expect(p.slug).to eql mock.slug
            end
          end
        end
      end
    end

  end
end