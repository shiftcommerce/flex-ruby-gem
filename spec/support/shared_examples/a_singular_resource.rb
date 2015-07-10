#
# Shared examples for a singular json-api resource
#
# Expected methods to be defined in the scope (normally using let)
#
# @param [String|Symbol] primary_key (Defaults to "id") Allows you to specify a different primary key for the resource when doing find operations
# @param [Object] resource_identifier The "resource identifier" (in json-api terms) which contains the resource
# @param [Class] subject_class The class of the subject under test
RSpec.shared_examples_for("a singular resource") do
  it "should return an object of the correct class when find is called" do
    pk = try(:primary_key) || :id
    id = resource_identifier.attributes.to_h.merge(resource_identifier.to_h.reject { |k| k == :attributes })[pk]
    subject_class.find(id).tap do |result|
      expect(result.id).to eql resource_identifier.id
      expect(result.type).to be_a String
      expect(result).to be_a subject_class
    end
  end
end
