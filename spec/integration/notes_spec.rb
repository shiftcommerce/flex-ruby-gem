require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Note do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  let(:singular_resource) { build(:note_from_fixture) }
  let(:resource_list) { build(:note_list_from_fixture) }

  context "index" do
    before :each do
      stub_request(:get, "#{api_root}/notes.json_api?filter%5Bcustomer_account_id%5D=1").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: resource_list.to_json, status: response_status, headers: default_headers
    end

    subject { subject_class.where(customer_account_id: 1).all }

    let(:subject_class) { FlexCommerce::Note }
    let(:quantity) { 2 }
    let(:total_pages) { 1 }
    let(:current_page) { 1 }
    let(:expected_list_quantity) { 2 }

    it_should_behave_like "a collection of anything"
  end

  context "show" do
    before :each do
      stub_request(:get, "#{api_root}/notes.json_api?filter%5Bcustomer_account_id%5D=1&page%5Bnumber%5D=1&page%5Bsize%5D=1").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
    end

    subject { FlexCommerce::Note.where(customer_account_id: 1).first }

    it "returns a correct note" do
      expect(subject.contents).to eq "Nemo aut nobis tempore quaerat quisquam qui suscipit."
    end
  end
end
