require 'spec_helper'

describe FlexCommerceApi::JsonApiClientExtension::ParseJson do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  it "includes malformed json in the thrown error when parsing fails" do
    stub_request(:get, "#{api_root}/addresses/1.json_api")
      .with(headers: default_request_headers)
      .to_return(
        body: {"key": "some_random_value"}.to_json,
        status: response_status,
        headers: default_headers
    )

    allow(JSON).to receive(:parse)
      .and_raise(
        JSON::ParserError,
        "quoted string not terminated at line 1, column 13937 [parse.c:337]"
    )

    expect{ FlexCommerce::Address.find(1) }.to raise_error do |error|
      expect(error).to be_a(JSON::ParserError)
      expect(error.raven_context).to eq({
        extra: {
          body: {"key": "some_random_value"}.to_json,
        }
      })
    end
  end
end
