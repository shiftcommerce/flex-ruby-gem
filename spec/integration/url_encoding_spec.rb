require "spec_helper"
require "flex_commerce_api"
require "flex_commerce_api/api_base"
require "uri"

RSpec.describe "url encoding on any model" do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) do
    TempClass ||= Class.new(FlexCommerceApi::ApiBase) { ; }
  end
  let(:empty_data) do
    {
      id: "1",
      type: "base",
      data: {}
    }
  end

  it "should allow a : in the url as it is required for the shift commerce app" do
    stub_request(:get, /\/temp_classes\/slug:my_slug\.json_api$/).to_return do |req|
      {body: empty_data.to_json, headers: default_headers, status: 200}
    end
    result = subject_class.find("slug:my_slug")
    expect(result).not_to be_nil
  end
end
