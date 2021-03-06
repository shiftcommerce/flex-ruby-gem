#
# Shared examples for a collection of json-api resources with a error responses
#
# Expected methods to be defined in the scope (normally using let)
#
# A request stub using "resource_list" should have been setup in your test which is used in the stubbed response
# and it should use "response_status" for the status code
# and the 'subject' should be the setup to perform the action you are testing and return the result
#
#
# @param [Class] subject_class The class of the subject under test
RSpec.shared_examples_for("a collection of resources with an error response") do
  context "with an exception raised by the server (500)" do
    let(:resource_list) { build(:error_exception) }
    let(:response_status) { 500 }
    it "should throw an internal server exception" do
      expect {subject}.to raise_exception(::FlexCommerceApi::Error::InternalServer)
    end
  end
  context "with an exception with an unknown meaning" do
    let(:resource_list) { build(:error_exception) }
    let(:response_status) { 600 }
    it "should throw an unexpected status exception" do
      expect {subject}.to raise_exception(::FlexCommerceApi::Error::UnexpectedStatus)
    end
  end
  context "with a not found exception (404)" do
    let(:resource_list) { build(:error_exception) }
    let(:response_status) { 404 }
    it "should throw a not found exception" do
      expect {subject}.to raise_exception(::FlexCommerceApi::Error::NotFound)
    end
  end
  context "with an access denied exception (403)" do
    let(:resource_list) { build(:error_exception) }
    let(:response_status) { 403 }
    it "should throw a not found exception" do
      expect {subject}.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
    end
  end
end
