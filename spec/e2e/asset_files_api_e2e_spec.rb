require "e2e_spec_helper"
RSpec.describe "Asset Files API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"
  include_context "housekeeping"

  # We define the model in advance, mainly allowing the code in the examples to be fairly generic and can be copied / pasted
  # into other tests without changing the model all over the place.
  let(:model) { FlexCommerce::AssetFile }

  # Globals - Mainly for fixture objects that any test can use
  let(:global_asset_folder) do
    to_clean.global_asset_folder ||= FlexCommerce::AssetFolder.create! name: "asset folder for Test Asset File #{uuid}",
                                                                       reference: "reference_for_asset_folder_1_for_asset_file_#{uuid}"
  end
  let(:asset_file_fixture_file) { File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__)) }

  context "#create" do
    let(:uuid) { SecureRandom.uuid }
    let!(:asset_folder) { global_asset_folder }
    it "should persist when valid attributes are used" do
      http_request_tracker.clear
      model.create! name: "name for Test Asset File #{uuid}",
                                    reference: "reference_for_test_asset_file_#{uuid}",
                                    asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                    asset_folder_id: asset_folder.id
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_file.json")
    end
  end

end