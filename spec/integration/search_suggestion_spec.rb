require "spec_helper"
require "flex_commerce_api"
RSpec.describe FlexCommerce::SearchSuggestion do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { FlexCommerce::SearchSuggestion }
  context "creating" do
    let(:search_suggestion_attributes) { attributes_for(:search_suggestion) }
    let(:expected_headers) { {"Accept" => "application/vnd.api+json"} }
    let(:search_suggestion_response) do
      {
        data: [
          {
            type: "search_suggestions",
            attributes: {
              text: "dog blanket"
            }
          },
          {
            type: "search_suggestions",
            attributes: {
              text: "dog guard"
            }
          }
        ]
      }
    end
    let!(:stub) { stub_request(:get, "#{api_root}/search_suggestions.json_api").with(query: {filter: {field: "title", scope: "product", query: "dog"}}, headers: expected_headers).to_return body: search_suggestion_response.to_json, status: response_status, headers: default_headers }
    # Find
    it "should find a search_suggestion" do
      search_suggestions = subject_class.where(scope: :product, field: "title", query: "dog").all
      expect(search_suggestions).to be_a(Array)
      expect(search_suggestions.length).to eql search_suggestion_response[:data].length
      expect(search_suggestions.first.text).to eql "dog blanket"
      expect(search_suggestions.last.text).to eql "dog guard"
    end
  end
end
