require "e2e_spec_helper"
RSpec.describe "Asset folders API end to end spec", vcr: true do
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
  let(:model) { FlexCommerce::AssetFolder }

  # Globals - used mainly for fixture data
  let(:asset_file_fixture_file) do
    # Create an asset file for use by the test
    File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
  end

  let(:uuid) { SecureRandom.uuid }

  context "#create" do
    it "should persist when valid attributes are used" do
      subject = keep_tidy do
        FlexCommerce::AssetFolder.create! reference: "reference for asset folder #{uuid}",
                                          name: "name for asset folder #{uuid}"
      end
      expect(subject.errors).to be_empty
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
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
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
      expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
      subject = FlexCommerce::AssetFolder.includes("asset_files").find(created_resource.id).first
      expect(subject.asset_files).to contain_exactly an_object_having_attributes name: "name for asset file for asset folder #{uuid}"

    end
  end

  context "#read collection" do
    context "with caching", caching: true do

    end
  end
  context "#read member" do
    # Here we setup for all tests - we create the resource, then the test will read it
    let(:uuid) { SecureRandom.uuid }
    let!(:created_resource) do
      keep_tidy do
        model.create!(reference: "reference for asset folder #{uuid}",
                      name: "name for asset folder #{uuid}").freeze
      end
    end
    it "should have no default relationships included" do
      subject = model.find(created_resource.id)
      http_request_tracker.clear
      subject.asset_files
      subject.sub_folders
      expect(http_request_tracker.length).to eql 2
    end
    context "asset_files relationship" do
      let(:asset_file) do
        FlexCommerce::AssetFile.new(name: "name for Asset file 1 for Test Asset Folder #{uuid} temp",
                                    reference: "reference_for_asset_file_1_for_asset_folder_#{uuid} temp",
                                    asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}")
      end
      let!(:created_resource) do
        keep_tidy do
          model.create!(reference: "reference for asset folder #{uuid}",
                        name: "name for asset folder #{uuid}",
                        asset_files_resources: [asset_file]).freeze
        end
      end

      it "should exist" do
        subject = model.find(created_resource.id)
        expect(subject.relationships.asset_files).to be_present
      end

      it "should be loadable using compound documents" do
        http_request_tracker.clear
        subject = model.includes("asset_files").find(created_resource.id).first
        expect(subject.asset_files).to contain_exactly an_object_having_attributes asset_file.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 1
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
      end

      it "should be loadable using links" do
        http_request_tracker.clear
        subject = model.includes("").find(created_resource.id).first
        expect(subject.asset_files).to contain_exactly an_object_having_attributes asset_file.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 2
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
      end
    end

    context "sub_folders" do
      let(:sub_folder) do
        FlexCommerce::AssetFolder.new(reference: "reference for asset folder #{uuid}_1",
                                      name: "name for asset folder #{uuid}_1")
      end
      let!(:created_resource) do
        keep_tidy do
          model.create!(reference: "reference for asset folder #{uuid}",
                        name: "name for asset folder #{uuid}",
                        sub_folders_resources: [sub_folder]).freeze
        end
      end
      it "should exist" do
        subject = model.find(created_resource.id)
        expect(subject.relationships.sub_folders).to be_present
      end

      it "should be loadable using compound documents" do
        http_request_tracker.clear
        subject = model.includes("sub_folders").find(created_resource.id).first
        expect(subject.sub_folders).to contain_exactly an_object_having_attributes sub_folder.attributes.slice(:reference, :name)
        expect(http_request_tracker.length).to eql 1
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
      end

      it "should be loadable using links" do
        http_request_tracker.clear
        subject = model.includes("").find(created_resource.id).first
        expect(subject.sub_folders).to contain_exactly an_object_having_attributes sub_folder.attributes.slice(:reference, :name)
        expect(http_request_tracker.length).to eql 2
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/asset_folder.json")
      end


    end
    context "with caching", caching: true do

    end


  end

  context "#update" do

  end

  context "#delete" do

  end

end