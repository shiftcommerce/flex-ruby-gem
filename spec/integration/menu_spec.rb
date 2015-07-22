require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Menu do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Menu }
  let(:menu_item_class) { ::FlexCommerce::MenuItem }
  let(:product_class) { ::FlexCommerce::Product }
  let(:singular_resource) { build(:menu) }
  context "with temporary mocked data" do
    before :each do
      stub_request(:get, "#{api_root}/menus/test-menu.json").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: 200, headers: default_headers
    end
    it "should return nested stuff" do
      subject_class.find("test-menu").tap do |result|
        expect(result).to be_a(subject_class)
        expect(result.menu_items.count).to eql 2
        expect(result.menu_items.first).to be_a(menu_item_class)
        expect(result.menu_items.first.menu_items.count).to eql 1
      end
    end

  end

  context "with fixture files from flex" do
    let(:singular_resource) { build(:menu_from_fixture) }
    before :each do
      stub_request(:get, "#{api_root}/menus/test-menu.json").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: 200, headers: default_headers
    end
    subject { subject_class.find("test-menu") }
    it "should return the correct top level object" do
      expect(subject).to be_a(subject_class)
      expect(subject.title).to eql singular_resource.data.attributes.title
    end
    it "should have the correct number of menu items" do
      expect(subject.menu_items.count).to eql singular_resource.data.relationships.menu_items.data.count
      subject.menu_items.each do |menu_item|
        expect(menu_item).to be_a(menu_item_class)
      end
    end
    it "each top level menu_item should have a nested menu item" do
      subject.menu_items.each do |menu_item|
        expect(menu_item.menu_items.count).to eql 2
        expect(menu_item.menu_items.first).to be_a(menu_item_class)
      end
    end
    it "should have a product attached to the top level menu items" do
      subject.menu_items.each do |menu_item|
        expect(menu_item.item).to be_a(product_class)
      end
    end
  end
end
