require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Slug do

  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  let(:resource_identifier) { build(:json_api_resource, build_resource: :slug, base_path: base_path) }
  let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }
  let(:subject_class) { ::FlexCommerce::Slug }

  context 'Finding a slug' do
    before do
      stub_request(:get, "#{api_root}/slugs/#{resource_identifier.id}.json_api")
                  .with(headers: { "Accept" => "application/vnd.api+json" })
                  .to_return body: singular_resource.to_h.to_json, 
                             status: response_status, 
                             headers: default_headers
    end

    it_should_behave_like "a singular resource"
  end
end