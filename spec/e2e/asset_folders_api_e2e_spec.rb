require "e2e_spec_helper"
RSpec.describe "Asset folders API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"

  def to_clean
    context_store.to_clean
  end

  def keep_tidy
    yield.tap do |o|
      to_clean.dumping_ground ||= []
      to_clean.dumping_ground << o
    end
  end

  def asset_file_fixture_file
    # Create an asset file for use by the test
    File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
  end

  # As setting up for testing can be very expensive, we do it only at the start of then context
  # it is then our responsibility to tidy up at the end of the context.
  before(:context) do
    uuid = SecureRandom.uuid
    context_store.to_clean = OpenStruct.new
  end
  # Clean up time - delete stuff in the reverse order to give us more chance of success
  after(:context) do
    to_clean.to_h.values.reverse.each do |resource|
      if resource.is_a?(Array)
        resource.each { |r| r.destroy if r.persisted? }
      else
        resource.destroy if resource.persisted?
      end
    end
  end
  let(:uuid) { SecureRandom.uuid }

  context "#create" do
    it "should persist when valid attributes are used" do
      subject = keep_tidy do
        FlexCommerce::AssetFolder.create! reference: "reference for asset folder #{uuid}",
                                          name: "name for asset folder #{uuid}"
      end
      expect(subject.errors).to be_empty
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/asset_folder")
    end
    it "should persist when valid attributes with a nested asset file are used" do
      created_resource = keep_tidy do
        FlexCommerce::AssetFolder.create! reference: "reference for asset folder #{uuid}",
                                          name: "name for asset folder #{uuid}",
                                          asset_files_resources: [
                                              FlexCommerce::AssetFile.new(name: "name for asset file for asset folder #{uuid}",
                                                                          reference: "reference_for_asset_file_for_asset_folder_#{uuid}",
                                                                          asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}")
                                          ]
      end
      expect(created_resource.errors).to be_empty
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/asset_folder")
      subject = FlexCommerce::AssetFolder.includes("asset_files").find(created_resource.id).first
      expect(subject.asset_files).to contain_exactly an_object_having_attributes name: "name for asset file for asset folder #{uuid}"

    end
  end

  context "#read" do
    context "collection" do
    end
    context "member" do

    end
  end

  context "#update" do

  end

  context "#delete" do

  end

end