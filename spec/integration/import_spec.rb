require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Import do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Import }
  let(:import_entry_class) { ::FlexCommerce::ImportEntry }

  context "with fixture files from flex" do
    context "working with a single import_entry tree" do
      let(:singular_resource) { build(:import_from_fixture) }

      before :each do
        stub_request(:get, "#{api_root}/imports/1.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
      end

      subject { subject_class.find(1) }
      it_should_behave_like "a singular resource with an error response"

      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
        expect(subject.title).to eql singular_resource.data.attributes.title
        expect(subject.reference).to eql singular_resource.data.attributes.reference
      end

      context "using the import entries association" do
        before :each do
          stub_request(:get, "#{flex_root}#{singular_resource.data.relationships.import_entries.links.related}").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: multiple_import_entry_resources.to_h.to_json, status: response_status, headers: default_headers
          stub_request(:get, "#{flex_root}#{singular_resource.data.relationships.import_entries.links.related}.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: multiple_import_entry_resources.to_h.to_json, status: response_status, headers: default_headers
        end

        let(:multiple_import_entry_resources) { build(:import_entries_from_fixture) }

        it "should return a list of import_entries" do
          subject.import_entries.tap do |import_entries|
            expect(import_entries.length).to eql multiple_import_entry_resources.data.length
            import_entries.each_with_index do |import_entry, idx|
              expect(import_entry).to be_a(import_entry_class)
            end
          end
        end

        it "should return a list of import_entries with the correct attributes" do
          subject.import_entries.tap do |import_entries|
            expect(import_entries.length).to eql multiple_import_entry_resources.data.length
            import_entries.each_with_index do |import_entry, idx|
              resource = multiple_import_entry_resources.data[idx]
              resource.attributes.each_pair do |attr, value|
                expect(import_entry.send(attr)).to eql value
              end
            end
          end
        end
      end
    end

    context "working with multiple import_entry trees" do
      let(:resource_list) { build(:imports_from_fixture) }
      let(:quantity) { 2 }
      let(:total_pages) { resource_list.meta.page_count }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 2 }
      subject { subject_class.all }

      before :each do
        stub_request(:get, "#{api_root}/imports.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end

      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"
    end
  end
end
