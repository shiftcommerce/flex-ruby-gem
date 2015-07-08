RSpec.shared_context "global context" do
  let(:flex_root_url) { FlexCommerceApi.config.flex_root_url }
  let(:api_root) do
    URI.parse("#{flex_root_url}/#{FlexCommerceApi::API_VERSION}").tap do |u|
      u.user = "testaccount"
      u.password = FlexCommerceApi.config.flex_api_key
    end.to_s
  end
  let(:default_headers) {  {"Content-Type": "application/json"} }
end