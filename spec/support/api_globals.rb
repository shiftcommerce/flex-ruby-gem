RSpec.shared_context "global context" do |api_version: "v1"|
  before(:each) { WebMock.reset! }
  let(:flex_root_url) { FlexCommerceApi.config.flex_root_url }
  let(:flex_account) { FlexCommerceApi.config.flex_account }
  let(:api_root) do
    URI.parse("#{flex_root_url}/#{flex_account}/#{api_version}").tap do |u|
      u.user = flex_account
      u.password = FlexCommerceApi.config.flex_api_key
    end.to_s
  end
  let(:flex_root) do
    URI.parse(flex_root_url).tap do |u|
      u.user = flex_account
      u.password = FlexCommerceApi.config.flex_api_key
    end.to_s
  end
  let(:default_headers) { {"Content-Type": "application/json"} }
  let(:default_request_headers) { {"Accept" => "application/vnd.api+json", :"Content-Type" => "application/vnd.api+json"} }
  let(:page_size) { 25 }
  let(:base_path) { URI.parse(api_root).path }
  let(:response_status) { 200 }
end
