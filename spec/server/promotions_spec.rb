require "spec_helper"
require "flex_commerce_api"

describe "Server Promotions Spec", :server do
  def test_class
    FlexCommerce::Promotion
  end
  include_context "server context"
  context "full CRUD" do
    include_context "server crud context"
    created_resource = nil
    original_created_resource_id = nil
    before(:context) do
      setup_for_api!
      created_resource = test_class.create attributes_for(:promotion, :fixed_amount)
      original_created_resource_id = created_resource.id
    end
    after(:context) do
      setup_for_api!
      created_resource.destroy rescue nil unless created_resource.nil?
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
        let(:found_resources) { test_class.all }
        it "should include the created resource" do
          expect(found_resources.map(&:id)).to include(created_resource.id)
        end
      end
      context "#find" do
        let(:found_resource) { test_class.find(created_resource.id) }
        it "should match the created resource" do
          expect(found_resource.id).to eql(created_resource.id)
        end
      end

    end
    context "update" do
      let(:resource_to_update) { test_class.find(created_resource.id) }
      let(:updated_resource) { test_class.find(created_resource.id) }
      it "should persist a change to the resource" do
        new_attrs = { name: "#{resource_to_update.name} - renamed" }
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
        let(:found_resources) { test_class.all }
        it "should not include the created resource" do
          expect(found_resources.map(&:id)).not_to include(created_resource.id)
        end
      end
      context "#find" do
        it "should not find the resource" do
          expect {test_class.find(original_created_resource_id)}.to raise_exception FlexCommerceApi::Error::NotFound
        end
      end
    end
  end
end