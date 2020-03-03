require "spec_helper"
require "flex_commerce_api"

describe "Server Asset Files Spec", :server do
  def test_class
    FlexCommerce::AssetFile
  end
  include_context "server context"
  context "full CRUD" do
    include_context "server crud context"
    created_resource = nil
    created_asset_folder = nil
    original_created_resource_id = nil
    before(:context) do
      setup_for_api!
      created_asset_folder = FlexCommerce::AssetFolder.create attributes_for(:asset_folder)
      created_resource = test_class.create attributes_for(:asset_file, asset_folder_id: created_asset_folder.id)
      original_created_resource_id = created_resource.id
    end
    after(:context) do
      setup_for_api!
      unless created_resource.nil?
        begin
          created_resource.destroy
        rescue
          nil
        end
      end
      teardown_for_api!
    end
    context "create" do
      it "should be persisted with no errors" do
        expect(created_resource.errors).to be_empty
        expect(created_resource).to be_persisted
      end
    end
    context "read" do
      context "#all" do
        let(:found_resources) { test_class.where(asset_folder_id: created_asset_folder.id).all }
        it "should include the created resource" do
          expect(found_resources.map(&:id)).to include(created_resource.id)
        end
      end
      context "#find" do
        let(:found_resource) { test_class.where(asset_folder_id: created_asset_folder.id).find(created_resource.id).first }
        it "should match the created resource" do
          expect(found_resource.id).to eql(created_resource.id)
        end
      end
    end
    context "update" do
      let(:resource_to_update) { test_class.where(asset_folder_id: created_asset_folder.id).find(created_resource.id).first }
      let(:updated_resource) { test_class.where(asset_folder_id: created_asset_folder.id).find(created_resource.id).first }
      it "should persist a change to the resource" do
        new_attrs = {name: "#{resource_to_update.name} - renamed"}
        resource_to_update.update_attributes new_attrs
        expect(updated_resource.name).to eql new_attrs[:name]
      end
    end
    context "delete" do
      it "should destroy without erroring" do
        created_resource.destroy
      end
    end
    context "read again" do
      context "#all" do
        let(:found_resources) { test_class.where(asset_folder_id: created_asset_folder.id).all }
        it "should not include the created resource" do
          expect(found_resources.map(&:id)).not_to include(created_resource.id)
        end
      end
      context "#find" do
        it "should not find the resource" do
          expect { test_class.where(asset_folder_id: created_asset_folder.id).find(original_created_resource_id) }.to raise_exception FlexCommerceApi::Error::NotFound
        end
      end
    end
  end
end
