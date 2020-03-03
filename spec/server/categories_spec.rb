require "spec_helper"
require "flex_commerce_api"

describe "Server Categories Spec", :server do
  def test_class
    FlexCommerce::Category
  end
  include_context "server context"
  context "full CRUD" do
    include_context "server crud context"
    created_resource = nil
    original_created_resource_id = nil
    before(:context) do
      setup_for_api!
      created_resource = test_class.create attributes_for(:category)
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
        let(:found_resources) { test_class.where(category_tree_id: "reference:web").page(1).per(100).all }
        it "should include the created resource" do
          expect(found_resources.map(&:id)).to include(created_resource.id)
        end
      end
      context "#find" do
        let(:found_resource) { test_class.where(category_tree_id: "reference:web").find(created_resource.id).first }
        it "should match the created resource" do
          expect(found_resource.id).to eql(created_resource.id)
        end
      end
    end
    context "update" do
      let(:resource_to_update) { test_class.where(category_tree_id: "reference:web").find(created_resource.id).first }
      let(:updated_resource) { test_class.where(category_tree_id: "reference:web").find(created_resource.id).first }
      it "should persist a change to the resource" do
        new_attrs = {title: "#{resource_to_update.title} - renamed"}
        resource_to_update.update_attributes new_attrs
        expect(updated_resource.title).to eql new_attrs[:title]
      end
    end
    context "delete" do
      it "should destroy without erroring" do
        created_resource.destroy
      end
    end
    context "read again" do
      context "#all" do
        let(:found_resources) { test_class.where(category_tree_id: "reference:web").all }
        it "should not include the created resource" do
          expect(found_resources.map(&:id)).not_to include(created_resource.id)
        end
      end
      context "#find" do
        it "should not find the resource" do
          expect { test_class.where(category_tree_id: "reference:web").find(original_created_resource_id) }.to raise_exception FlexCommerceApi::Error::NotFound
        end
      end
    end
  end
  context "pagination" do
    context "with small page size" do
      page_size = nil
      collection = nil
      before(:context) do
        setup_for_api!
        page_size = 3
        collection = page_size.times.map {
          test_class.create! attributes_for(:category)
        }
      end
      after(:context) do
        setup_for_api!
        collection.each do |category|
          category.destroy
        end
      end
      context "#all" do
        context "on the first page" do
          let(:found_resources) { test_class.where(category_tree_id: "reference:web").page(1).per(page_size).all }
          it "should contain the correct number of resources" do
            expect(found_resources.length).to eql page_size
          end
        end
        context "on the last page" do
          let(:found_resources) { test_class.where(category_tree_id: "reference:web").page(2).per(page_size).all }
          it "should contain the correct number of resources" do
            expect(found_resources.length).to eql ((found_resources.total_count - 1) % page_size) + 1
          end
        end
      end
    end
  end
end
