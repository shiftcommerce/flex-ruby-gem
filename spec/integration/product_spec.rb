require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Product do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  # The quantity of items to create - changes in different contexts
  let(:quantity) { 0 }
  # The product list - build 'quantity' of them
  let(:resource_list) { build(:product_list, quantity: quantity, base_path: base_path) }
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::Product }

  # As the same examples are used in several different contexts
  # to save repeating ourselves, a shared example is defined here
  # which tests for anything common to a collection of products
  shared_examples_for("a collection of products") do
    it_should_behave_like "a collection of anything"
    it "should return the correct number of instances and the meta data should be correct" do
      subject.each_with_index do |p, idx|
        resource_list.data[idx].tap do |resource_identifier|
          expect(p.id).to eql(resource_identifier.id)
          expect(p.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(resource_identifier.attributes.as_json)
        end
      end
    end
  end
  # |---------------------------------------------------------|
  # | Examples Start Here                                     |
  # |---------------------------------------------------------|

  #
  # All collection examples
  #
  context "using a collection of products" do
    # Convenient access to the expected total pages of data
    let(:total_pages) { (quantity / page_size.to_f).ceil.to_i }
    # The current page - changes in different contexts
    let(:current_page) { nil }
    # Calculates the stubbed_url depending on if current_page is nil or not
    #  If current page is nil, then it is expected that the test will fetch its data from the collection_url rather
    #  than the paginated version.
    let(:stubbed_url) { current_page.present? ? "#{collection_url}/pages/#{current_page}.json_api" : "#{collection_url}.json_api" }
    # Calculates the expected list quantity
    let(:expected_list_quantity) { quantity == 0 ? 0 : ((quantity - 1) % page_size) + 1 }
    context "without search" do
      # Easy access to the collection URL
      let(:collection_url) { "#{api_root}/products" }
      let!(:stub) { stub_request(:get, stubbed_url).with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_json, status: response_status, headers: default_headers }
      # The subject for all examples - using pagination as this is expected normally
      subject { subject_class.paginate(page: current_page).all }
      it_should_behave_like "a collection of resources with various data sets", resource_type: :product
      it_should_behave_like "a collection of resources with an error response"
    end
    # temp_search is temporary until we defined a standard for searching all collections
    # when the real search is implemented, this spec must be enhanced - it checks for basics at the moment
    context "using temp_search" do
      # Calculates the stubbed_url depending on if current_page is nil or not
      #  If current page is nil, then it is expected that the test will fetch its data from the collection_url rather
      #  than the paginated version.
      let(:stubbed_url) do
        URI.parse(current_page.present? ? "#{collection_url}/pages/#{current_page}.json_api" : "#{collection_url}.json_api").tap do |u|
          u.query = { filter: search_criteria }.to_query
        end.to_s
      end

      # The subject for all examples - using pagination as this is expected normally
      subject do
        subject_class.temp_search(query: "Shirt", fields: "description,reference,slug").paginate(page: current_page).all
      end
      let(:expected_body) do
        {
          "data": {

          }
        }
      end
      # Easy access to the collection URL
      let(:collection_url) { "#{api_root}/products/search" }
      let(:quantity) { 50 }
      let(:search_criteria) { { query: "Shirt", fields: "description,reference,slug" } }
      let!(:stub) do
        stub_request(:get, stubbed_url).with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_json, status: response_status, headers: default_headers
      end

      it_should_behave_like "a collection of anything"
    end
  end

  context "using fixture data for a collection of products" do
    let(:resource_list) { build(:product_list_from_fixture) }
    let(:quantity) { resource_list.data.count }
    let(:total_pages) { 1 }
    let(:expected_list_quantity) { 10 }
    let(:current_page) { nil }
    before :each do
      stub_request(:get, "#{api_root}/products.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
    end
    subject { subject_class.paginate(page: current_page).all }
    it_should_behave_like "a collection of anything"
    it "should have the correct attributes from the fixture" do
      subject.each_with_index do |product, idx|
        resource_list.data[idx].tap do |pr|
          expect(product.id).to eql pr.id
          pr.attributes.each_pair do |attr, value|
            expect(product.send(attr)).to eql value
          end
        end
      end
    end
  end

  #
  # Member Examples
  #
  context "using a single resource" do
    let(:variants_count) { 5 }
    let(:breadcrumbs_count) { 2 }
    let(:variant_resources) { build_list(:json_api_resource, variants_count, build_resource: :variant) }
    let(:breadcrumb_resources) { build_list(:json_api_resource, breadcrumbs_count, build_resource: :breadcrumb, type: :breadcrumbs) }
    let(:variant_relationship) { { variants: {
        data: variant_resources.map { |vr| { type: "variants", id: vr.id }}
    } } }
    let(:breadcrumb_relationship) { { breadcrumbs: {
        data: breadcrumb_resources.map { |br| { type: "breadcrumbs", id: br.id }}
    } } }
    let(:variant_class) { FlexCommerce::Variant }
    let(:breadcrumb_class) { FlexCommerce::Breadcrumb }
    let(:resource_identifier) { build(:json_api_resource, build_resource: :product, relationships: variant_relationship.merge(breadcrumb_relationship), base_path: base_path, primary_key: :slug) }
    let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier, included: variant_resources + breadcrumb_resources) }
    let(:primary_key) { :slug }
    before :each do
      stub_request(:get, "#{api_root}/products/#{resource_identifier.attributes.slug}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
    end
    context "finding a single resource" do
      it_should_behave_like "a singular resource"
      context "using the primary key" do
        subject { subject_class.find(resource_identifier.attributes.send(primary_key)) }
        it_should_behave_like "a singular resource with an error response"
        it "should return an object with the correct attributes when find is called" do
          expect(subject.attributes.as_json.reject { |k| %w(id type links meta variants relationships).include?(k) }).to eql(resource_identifier.attributes.as_json.reject { |k| %w(variants).include?(k) })
          expect(subject.type).to eql "products"
        end
      end
      context "using the slug" do
        subject { subject_class.find(resource_identifier.attributes.slug) }
        it_should_behave_like "a singular resource with an error response"
        it "should get the associated variants" do
          subject.variants.tap do |variant_list|
            expect(variant_list.length).to eql variants_count
            variant_list.each_with_index do |v, idx|
              mocked_variant = variant_resources[idx].attributes
              expect(v).to be_a(variant_class)
              expect(v.type).to eql "variants"
              expect(v.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(mocked_variant.as_json)
            end
          end
        end
      end

      it "should get the associated breadcrumbs" do
        subject_class.find(resource_identifier.attributes.slug).tap do |result|
          result.breadcrumbs.tap do |breadcrumb_list|
            expect(breadcrumb_list.length).to eql breadcrumbs_count
            breadcrumb_list.each_with_index do |b, idx|
              mocked_breadcrumb = breadcrumb_resources[idx].attributes
              expect(b).to be_a(breadcrumb_class)
              expect(b.type).to eql "breadcrumbs"
              expect(b.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(mocked_breadcrumb.as_json)
            end
          end
        end

      end
      it "should find a single breadcrumb by using the find method similar to active record" do
        mocked_breadcrumb = breadcrumb_resources.last
        subject_class.find(resource_identifier.attributes.slug).tap do |result|
          result.breadcrumbs.find(mocked_breadcrumb.attributes.reference).tap do |breadcrumb|
            expect(breadcrumb).to be_a(breadcrumb_class)
            expect(breadcrumb.type).to eql "breadcrumbs"
            expect(breadcrumb.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(mocked_breadcrumb.attributes.as_json)
          end
        end

      end
    end
  end

  context "using fixture data for a single resource" do
    let(:singular_resource) { build(:product_from_fixture) }
    let(:resource_identifier) { singular_resource.data }
    let(:primary_key) { :slug }
    let(:variant_class) { FlexCommerce::Variant }
    let(:variant_resources) do
      resource_identifier.relationships.variants.data.map do |ri|
        singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
      end
    end
    before :each do
      stub_request(:get, "#{api_root}/products/#{resource_identifier.attributes.slug}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: 200, headers: default_headers
    end
    it_should_behave_like "a singular resource"
    context "with subject set" do
      subject { subject_class.find(resource_identifier.attributes.slug) }
      it "should return an object with the correct attributes" do
        resource_identifier.attributes.each_pair do |attr, value|
          value = value.to_h if value.is_a?(JsonStruct)
          expect(subject.send(attr)).to eql(value), "Expected #{attr} attribute to be #{value} but it was #{subject.send(attr)}"
        end
      end
      context "variants" do
        it "should have the correct number of variants" do
          expect(subject.variants.count).to eql resource_identifier.relationships.variants.data.count
          subject.variants.each_with_index do |variant, idx|
            expect(variant).to be_a(variant_class)
          end
        end
        it "should have the correct attributes for the variants" do
          subject.variants.each_with_index do |variant, idx|
            expect(variant.id).to eql(variant_resources[idx].id)
            variant_resources[idx].attributes.each_pair do |attr, value|
              expect(variant.send(attr)).to eql value
            end
          end
        end
      end
      it_should_behave_like "any resource with breadcrumbs"
    end
  end
end
