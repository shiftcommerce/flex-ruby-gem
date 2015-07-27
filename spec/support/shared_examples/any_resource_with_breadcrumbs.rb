#
# Shared examples for any singular json-api resource that is expected to have breadcrumbs
#
# Expected methods to be defined in the scope (normally using let)
#
# @param [Object] resource_identifier The "resource identifier" (in json-api terms) which contains the resource
# @param [Class] subject_class The class of the subject under test
RSpec.shared_examples_for("any resource with breadcrumbs") do
  context "breadcrumbs" do
    let(:breadcrumb_class) { FlexCommerce::Breadcrumb }
    let(:breadcrumb_item_class) { FlexCommerce::BreadcrumbItem }
    let(:breadcrumb_resources) do
      resource_identifier.relationships.breadcrumbs.data.map do |ri|
        singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
      end
    end
    it "should have the correct amount of breadcrumbs" do
      expect(subject.breadcrumbs.count).to eql resource_identifier.relationships.breadcrumbs.data.count
    end
    it "should have the correct type for each breadcrumb" do
      subject.breadcrumbs.each do |breadcrumb|
        expect(breadcrumb).to be_a(breadcrumb_class)
      end
    end
    it "should have the correct attributes for each breadcrumb" do
      subject.breadcrumbs.each_with_index do |breadcrumb, idx|
        expect(breadcrumb.id).to eql(breadcrumb_resources[idx].id)
        breadcrumb_resources[idx].attributes.each_pair do |attr, value|
          expect(breadcrumb.send(attr)).to eql value
        end
      end
    end
    it "should have a single breadcrumb item per breadcrumb which refers to the item" do
      subject.breadcrumbs.each_with_index do |breadcrumb, idx|
        expect(breadcrumb.breadcrumb_items.count).to eql 1
        breadcrumb.breadcrumb_items.first.tap do |item|
          expect(item).to be_a breadcrumb_item_class
          breadcrumb_item_resources = breadcrumb_resources[idx].relationships.breadcrumb_items.data.map do |ri|
            singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
          end
          breadcrumb_item_resources.first.attributes.each_pair do |attr, value|
            expect(item.send(attr)).to eql value
          end
          breadcrumb_item_resources.first.tap do |item_resource|
            expect(item.item).to be_a(subject_class)
            item_resources = [item_resource.relationships.item.data].map do |ri|
              singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
            end
            expect(item.item.id).to eql item_resources.first.id
            item_resources.first.attributes.each_pair do |attr, value|
              expect(item.item.send(attr)).to eql value
            end
          end
        end
      end
    end
  end
end
