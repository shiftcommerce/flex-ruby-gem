require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::CustomerAccount do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::CustomerAccount }

  # |---------------------------------------------------------|
  # | Examples Start Here                                     |
  # |---------------------------------------------------------|

  #
  # Member Examples
  #
  context "using a single resource" do
    let(:resource_identifier) { build(:json_api_resource, build_resource: :customer_account, base_path: base_path) }
    let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }
    let(:write_headers) { { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" } }
    before :each do
      stub_request(:get, "#{api_root}/customer_accounts/#{resource_identifier.id}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
    end
    context "finding a single resource" do
      it_should_behave_like "a singular resource"
      context "using the primary key" do
        subject { subject_class.find(resource_identifier.id) }
        it_should_behave_like "a singular resource with an error response"
        it "should return an object with the correct attributes when find is called" do
          expect(subject.attributes.as_json.reject { |k| %w(id type links meta relationships password).include?(k) }.with_indifferent_access).to eql(resource_identifier.attributes.as_json.with_indifferent_access)
          expect(subject.type).to eql "customer_accounts"
        end
        it "should return nil if an attribute is fetched that is not defined" do
          expect(subject.undefined_attribute).to be_nil
        end
        context "updating an undefined attribute" do
          let(:patch_headers) { { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" } }
          let(:patch_body) do
            {
              data: {
                id: resource_identifier.id.to_s,
                type: "customer_accounts",
                attributes: {
                  my_new_attr: "my new value"
                }
              }
            }
          end
          let!(:update_stub) { stub_request(:patch, "#{api_root}/customer_accounts/#{resource_identifier.id}.json_api").with(headers: patch_headers, body: patch_body).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers }
          it "should set an attribute when an undefined setter is called and then the record is saved" do
            subject.my_new_attr = "my new value"
            expect(subject.save).to be_truthy
          end
        end
      end
    end
    context "password resetting" do
      let(:account) { build(:customer_account) }
      let(:email_to_reset) { account.email }
      let(:encoded_email) { URI.encode_www_form_component(email_to_reset) }
      context "generating token" do
        let(:reset_link_with_placeholder) { "http://dummy.com/reset_password?email={{ email }}&token={{ token }}" }
        subject { subject_class.generate_token(email: email_to_reset, reset_link_with_placeholder: reset_link_with_placeholder) }
        let(:generate_token_body) do
          {
            data: {
              type: "customer_accounts",
              attributes: {
                reset_link_with_placeholder: reset_link_with_placeholder
              }
            }
          }
        end
        let!(:generate_token_stub) { stub_request(:post, "#{api_root}/customer_accounts/email:#{encoded_email}/resets.json_api").with(headers: write_headers, body: generate_token_body).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers }
        it "should return an instance which can then be reset using the token" do
          expect(subject).to be_a(subject_class)
        end
        context "with a more complex email" do
          let(:account) { build(:customer_account, email: "email+extra@domain.com") }
          it "should return an instance which can then be reset using the token" do
            expect(subject).to be_a(subject_class)
          end
        end
      end

      context "performing the reset" do
        let(:reset_password_token) { "reset_password_token" }
        let(:new_password) { "new_password" }
        subject { subject_class.reset_password(email: email_to_reset, reset_password_token: reset_password_token, password: new_password) }
        let(:reset_password_body) do
          {
            data: {
              type: "customer_accounts",
              attributes: {
                "password": new_password
              }
            }
          }
        end
        let!(:reset_password_stub) { stub_request(:patch, "#{api_root}/customer_accounts/email:#{encoded_email}/resets/token:#{reset_password_token}.json_api").with(headers: write_headers, body: reset_password_body).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers }
        it "should return an instance" do
          expect(subject).to be_a(subject_class)
        end
      end

    end
    context "authenticating" do
      let(:expected_body) {
        {
            data: {
                type: "customer_accounts",
                attributes: {
                    email: resource_identifier.attributes.email,
                    password: "correctpassword"
                }
            }
        }.with_indifferent_access
      }
      context "positive authentication" do
        before :each do
          stub_request(:post, "#{api_root}/customer_accounts/authentications.json_api").with(body: expected_body, headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.authenticate(email: resource_identifier.attributes.email, password: "correctpassword") }
        it "should return the logged in account" do
          expect(subject.email).to eql resource_identifier.attributes.email
          expect(subject.password).to be_nil
          expect(subject.id).to eql resource_identifier.id
        end
      end
      context "negative authentication" do
        let(:response_status) { 404 }
        let(:error_404) { build(:json_api_document, errors: [build(:json_api_error, status: "404", detail: "Not found", title: "Not found")]) }
        before :each do
          stub_request(:post, "#{api_root}/customer_accounts/authentications.json_api").with(body: expected_body, headers: { "Accept" => "application/vnd.api+json" }).to_return body: error_404.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.authenticate(email: resource_identifier.attributes.email, password: "correctpassword") }
        it "should return nil" do
          expect(subject).to be_nil
        end
      end
    end
  end

  context "using fixture data for a single resource" do
    let(:singular_resource) { build(:customer_account_from_fixture) }
    let(:resource_identifier) { singular_resource.data }
    before :each do
      stub_request(:get, "#{api_root}/customer_accounts/#{resource_identifier.id}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: 200, headers: default_headers
    end
    it_should_behave_like "a singular resource"
    context "with subject set" do
      subject { subject_class.find(resource_identifier.id) }
      it "should return an object with the correct attributes" do
        resource_identifier.attributes.each_pair do |attr, value|
          expect(subject.send(attr)).to eql value
        end
      end
    end
  end
end
