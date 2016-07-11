require "spec_helper"
require "flex_commerce_api"
RSpec.describe FlexCommerce::Redirect do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  let(:subject_class) { FlexCommerce::Redirect }

  describe ".find_by_resource" do
    it "should expect a path parameter" do
      expect {
        subject_class.find_by_resource(source_slug: "bla", source_type: "bla")
      }.to raise_error(ArgumentError)
    end

    it "should load a single Redirect when passing valid params" do
      stub_request(:get, /redirects.json_api/).with(headers: { Accept: 'application/vnd.api+json' }, query: hash_including(filter: anything)).to_return({
        body: File.read("./spec/fixtures/redirects/multiple.json"),
        status: 200,
        headers: default_headers
      })
      redirect = subject_class.find_by_resource(source_slug: "old-slug", source_type: "products", source_path: "/xyz")
      expect(redirect).to be_kind_of(subject_class)
    end
  end
end
