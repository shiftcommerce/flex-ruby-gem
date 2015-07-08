RSpec.shared_context "global context" do
  let(:api_root) do
    URI.parse("#{ENV["FLEX_ROOT_URL"]}/#{FlexCommerceApi::API_VERSION}").tap do |u|
      u.user = "testaccount"
      u.password = ENV["FLEX_API_KEY"]
    end.to_s
  end
  let(:default_headers) {  {"Content-Type": "application/json"} }
end