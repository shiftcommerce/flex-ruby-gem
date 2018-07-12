require "spec_helper"
require "flex_commerce_api"
require "flex_commerce_api/api_base"
require "uri"

RSpec.describe "capturing surrogate keys" do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) do
    TempClass ||= Class.new(FlexCommerceApi::ApiBase) do
    end
  end

  let(:empty_data) do
    {
      id: "1",
      type: "base",
      data: {}
    }
  end

  it "should capture surrogate keys from a single request" do
    headers = { "Content-Type": "application/json", "external-surrogate-key": "key1 key2" }

    stub_request(:get, /\/temp_classes\/test\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers, status: 200 }
    end

    keys = FlexCommerceApi::ApiBase.capture_surrogate_keys do
      subject_class.find('test')
    end

    expect(keys).to eq('key1 key2')
  end

  it "should combine surrogate keys from multiple requests" do
    headers_one = { "Content-Type": "application/json", "external-surrogate-key": "key1 key2" }
    headers_two = { "Content-Type": "application/json", "external-surrogate-key": "key3 key4" }

    stub_request(:get, /\/temp_classes\/test\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers_one, status: 200 }
    end

    stub_request(:get, /\/temp_classes\/test2\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers_two, status: 200 }
    end

    keys = FlexCommerceApi::ApiBase.capture_surrogate_keys do
      subject_class.find('test')
      subject_class.find('test2')
    end

    expect(keys).to eq('key1 key2 key3 key4')
  end

  it "should ensure duplicate surrogate keys are removed" do
    headers_one = { "Content-Type": "application/json", "external-surrogate-key": "key1 key2" }
    headers_two = { "Content-Type": "application/json", "external-surrogate-key": "key2 key3" }

    stub_request(:get, /\/temp_classes\/test\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers_one, status: 200 }
    end

    stub_request(:get, /\/temp_classes\/test2\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers_two, status: 200 }
    end

    keys = FlexCommerceApi::ApiBase.capture_surrogate_keys do
      subject_class.find('test')
      subject_class.find('test2')
    end

    expect(keys).to eq('key1 key2 key3')
  end

  it "should allow blank surrogate keys" do
    headers = { "Content-Type": "application/json" }

    stub_request(:get, /\/temp_classes\/test\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers, status: 200 }
    end

    keys = FlexCommerceApi::ApiBase.capture_surrogate_keys do
      subject_class.find('test')
    end

    expect(keys).to eq('')
  end

  it "should ensure surrogate keys are cleared between requests" do
    headers = { "Content-Type": "application/json", "external-surrogate-key": "key1 key2" }

    stub_request(:get, /\/temp_classes\/test\.json_api$/).to_return do |req|
      { body: empty_data.to_json, headers: headers, status: 200 }
    end

    Thread.current[:shift_surrogate_keys] = nil
    subject_class.find('test')
    expect(Thread.current[:shift_surrogate_keys]).to eq(nil)
  end
end
