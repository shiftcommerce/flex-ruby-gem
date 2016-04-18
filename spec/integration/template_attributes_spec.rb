require "spec_helper"
require "flex_commerce_api"
require "flex_commerce_api/api_base"

RSpec.describe "url encoding on any model" do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  let(:subject_class) do
    TemplateAttributableClass = Class.new(FlexCommerceApi::ApiBase) do
    end
  end
   
  before(:each) do
    stub_request(:get, /\/template_attributable_classes\/slug:my_slug\.json_api$/).to_return do |req|
      { body: example_data.to_json, headers: default_headers, status: 200 }
    end
  end

  context 'with template data of type text' do
    let!(:example_data) do
      { 
        data: {
          id: "1", 
          type: "template_attributable_class", 
          attributes: {
            template_attributes: { foo: { value: "bar", data_type: "text" } } 
          } 
        } 
      }
    end
   
    let(:result) { subject_class.find("slug:my_slug") }

    it 'allows get by template attribute method' do
      expect(result.template_attribute(:foo)).to eq "bar"
    end

    it 'does not allow get by direct reference to attribute' do
      expect(result.foo).to eq nil
    end
  end

  context 'with template data of type related-products' do
    let!(:example_data) do
      { 
        data: {
          id: "1", 
          type: "template_attributable_class", 
          attributes: {
            template_attributes: { template_related_products: { value: [1], data_type: "related-products" } }
          },
          relationships: {
            template_related_products: {
              data: [
                {
                  id: "1",
                  type: "template_attributable_class"
                }
              ]
            }
          }
        },
        included: [
          {
            id: "1",
            type: "template_attributable_class",
            attributes: {
              name: "Product image 1"
            }
          }
        ]
      }
    end
   
    let(:result) { subject_class.find("slug:my_slug") }

    it 'allows get by template attribute method' do
      expect(result.template_attribute(:template_related_products).map(&:id)).to eq ["1"]
    end

    it 'does allows get by direct reference to attribute' do
      expect(result.template_attribute(:template_related_products).map(&:id)).to eq ["1"]
    end
  end

  context 'with template data of type related-files' do
    let!(:example_data) do
      {
        data: {
          id: "1",
          type: "template_attributable_class",
          attributes: {
              template_attributes: { template_related_files: { value: [1], data_type: "related-files" } }
          },
          relationships: {
            template_related_files: {
              data: [
                {
                  id: "1",
                  type: "template_attributable_class"
                }
              ]
            }
          }
        },
        included: [
          {
            id: "1",
            type: "template_attributable_class",
            attributes: {
                name: "asset file 1"
            }
          }
        ]
      }
    end

    let(:result) { subject_class.find("slug:my_slug") }

    it 'allows get by template attribute method' do
      expect(result.template_attribute(:template_related_files).map(&:id)).to eq ["1"]
    end

    it 'does allows get by direct reference to attribute' do
      expect(result.template_attribute(:template_related_files).map(&:id)).to eq ["1"]
    end
  end
end