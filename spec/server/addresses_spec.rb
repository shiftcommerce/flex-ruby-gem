require "spec_helper"
require "flex_commerce_api"

describe "Server Addresses Spec", :server do
  def test_class
    FlexCommerce::Address
  end
  include_context "server context"
  context "full CRUD" do
    include_context "server crud context"
    created_resource = nil
    customer_account = nil
    original_created_resource_id = nil
    before(:context) do
      setup_for_api!
      customer_account = FlexCommerce::CustomerAccount.create(attributes_for(:customer_account, password: "12345test67890", password_confirmation: "12345test67890"))
      created_resource = test_class.where(customer_account_id: customer_account.id).build
      created_resource.update_attributes attributes_for(:address, customer_account_id: customer_account.id)
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
      begin
        customer_account.destroy
      rescue
        nil
      end
      teardown_for_api!
    end
    context "create" do
      it "should be persisted with no errors" do
        expect(customer_account.errors).to be_empty
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
      context "#customer_account.addresses" do
        let(:found_resources) { FlexCommerce::CustomerAccount.find(customer_account.id).addresses }
        it "should include the created resource" do
          expect(found_resources.map(&:id)).to include(created_resource.id)
        end
      end
      context "#find" do
        let(:found_resource) { test_class.find(created_resource.id) }
        it "should match the created resource" do
          expect(found_resource.id).to eql(created_resource.id)
        end
        it "should have a customer account" do
          expect(found_resource.customer_account).to be_a(FlexCommerce::CustomerAccount)
        end
      end
    end
    context "update" do
      let(:resource_to_update) { test_class.find(created_resource.id) }
      let(:updated_resource) { test_class.find(created_resource.id) }
      it "should persist a change to the resource" do
        new_attrs = {first_name: "#{resource_to_update.first_name} - renamed"}
        resource_to_update.update_attributes new_attrs
        expect(updated_resource.first_name).to eql new_attrs[:first_name]
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
          expect { test_class.find(original_created_resource_id) }.to raise_exception FlexCommerceApi::Error::NotFound
        end
      end
    end
  end
end
