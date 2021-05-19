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

      context "using the email address" do
        before :each do
          stub_request(:get, "#{api_root}/customer_accounts/email:#{resource_identifier.attributes.email}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.find_by_email(resource_identifier.attributes.email) }
        it_should_behave_like "a singular resource"
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

      context "using the reference" do
        before :each do
          stub_request(:get, "#{api_root}/customer_accounts/reference:#{resource_identifier.attributes.reference}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.find_by_reference(resource_identifier.attributes.reference) }
        it_should_behave_like "a singular resource"
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

      context "using the password reset token" do
        let(:password_reset_token) { "password_reset_token_from_email" }
        before :each do
          stub_request(:get, "#{api_root}/customer_accounts/token:#{password_reset_token}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.find_by_token(password_reset_token) }
        it_should_behave_like "a singular resource"
        it "should return an object with the correct attributes when find is called" do
          expect(subject.attributes.as_json.reject { |k| %w(id type links meta relationships password).include?(k) }.with_indifferent_access).to eql(resource_identifier.attributes.as_json.with_indifferent_access)
          expect(subject.type).to eql "customer_accounts"
        end
      end
    end

    context "password resetting" do
      context "getting password recovery status to check if token was used or expired" do
        let(:password_reset_token) { "password_reset_token_from_email" }
        let(:password_recovery_relationship) { { password_recovery: {
            data: { type: "password_recoveries", id: password_recovery_resource.id } }
        } }
        let(:resource_identifier) { build(:json_api_resource, build_resource: :customer_account, relationships: password_recovery_relationship, base_path: base_path) }
        let(:singular_resource_with_password_recovery) { build(:json_api_top_singular_resource, data: resource_identifier, included: [password_recovery_resource]) }
        let(:password_recovery_resource) { build(:json_api_resource, build_resource: :password_recovery) }
        let!(:find_by_token_stub) { stub_request(:get, "#{api_root}/customer_accounts/token:#{password_reset_token}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource_with_password_recovery.to_h.to_json, status: response_status, headers: default_headers }
        let(:resource) { subject_class.find_by_token(password_reset_token) }
        it "returns password_recovery resource in included section" do
          expect(resource.password_recovery).to be_kind_of(::FlexCommerce::PasswordRecovery)
        end
      end

      context "generating token" do
        let(:reset_link_with_placeholder) { "http://dummy.com/reset_password?email={{ email }}&token={{ token }}" }
        let(:response_status) { 201 }
        let!(:find_by_email_stub) { stub_request(:get, "#{api_root}/customer_accounts/email:#{resource_identifier.attributes.email}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers }
        let(:resource) { subject_class.find_by_email(resource_identifier.attributes.email) }
        subject { resource.generate_token(reset_link_with_placeholder: reset_link_with_placeholder) }
        let(:generate_token_body) do
          {
            data: {
              type: "password_recoveries",
              attributes: {
                reset_link_with_placeholder: reset_link_with_placeholder
              }
            }
          }
        end
        let(:password_recovery_resource) { build(:json_api_resource, build_resource: :password_recovery_with_valid_token, base_path: base_path) }
        let(:password_recovery_singular_resource) { build(:json_api_top_singular_resource, data: password_recovery_resource) }
        let!(:generate_token_stub) { stub_request(:post, "#{api_root}/customer_accounts/#{resource_identifier.id}/password_recovery.json_api").with(headers: write_headers, body: generate_token_body).to_return body: password_recovery_singular_resource.to_h.to_json, status: response_status, headers: default_headers }

        it "should return password_recovery resource if successfull" do
          expect(subject).to be_kind_of(::FlexCommerce::PasswordRecovery)
          expect(subject.errors).to be_blank
          expect(subject.token_present).to be_truthy
          expect(subject.token_expired).to be_falsey
        end
        context "when unsuccessfull" do
          let(:response_status) { 422 }
          let(:error_message) { "token creation failed" }
          let(:error_422) { build(:json_api_document, errors: [build(:json_api_error, status: "422", detail: error_message, title: error_message)]) }
          let!(:generate_token_stub) { stub_request(:post, "#{api_root}/customer_accounts/#{resource_identifier.id}/password_recovery.json_api").with(headers: write_headers, body: generate_token_body).to_return body: error_422.to_h.to_json, status: response_status, headers: default_headers }

          it "should return password_recovery resource with errors" do
            expect(subject).to be_kind_of(::FlexCommerce::PasswordRecovery)
            expect(subject.errors).to be_present
            expect(subject.errors.full_messages).to include(error_message)
          end
        end
      end

      context "performing the reset" do
        let(:password_recovery_relationship) { { password_recovery: {
            data: { type: "password_recoveries", id: password_recovery_resource.id } }
        } }
        let(:resource_identifier) { build(:json_api_resource, build_resource: :customer_account, relationships: password_recovery_relationship, base_path: base_path) }
        let(:singular_resource_with_password_recovery) { build(:json_api_top_singular_resource, data: resource_identifier, included: [password_recovery_resource]) }
        let(:password_recovery_resource) { build(:json_api_resource, build_resource: :password_recovery) }
        let!(:find_by_email_stub) { stub_request(:get, "#{api_root}/customer_accounts/email:#{resource_identifier.attributes.email}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource_with_password_recovery.to_h.to_json, status: response_status, headers: default_headers }
        let(:reset_password_token) { "reset_password_token" }
        let(:new_password) { "new_password" }
        let(:resource) { subject_class.find_by_email(resource_identifier.attributes.email) }
        subject { resource.reset_password(token: reset_password_token, password: new_password) }
        let(:reset_password_body) do
          {
            data: {
              type: "password_recoveries",
              attributes: {
                "token": reset_password_token,
                "password": new_password
              }
            }
          }
        end

        context "successfull reset_password" do
          let(:password_recovery_with_used_token_resource) { build(:json_api_resource, build_resource: :password_recovery_with_used_token, base_path: base_path) }
          let(:password_recovery_singular_resource) { build(:json_api_top_singular_resource, data: password_recovery_with_used_token_resource) }

          let!(:reset_password_stub) { stub_request(:patch, "#{api_root}/customer_accounts/#{resource_identifier.id}/password_recovery.json_api").with(headers: write_headers, body: reset_password_body).to_return body: password_recovery_singular_resource.to_h.to_json, status: response_status, headers: default_headers }
          it "should return password_recovery resource if successfull" do
            expect(subject).to be_kind_of(::FlexCommerce::PasswordRecovery)
            expect(subject.errors).to be_blank
            expect(subject.token_present).to be_falsey
            expect(subject.token_expired).to be_truthy
          end
        end

        context "failed reset_password due to invalid token" do
          let(:response_status) { 422 }
          let(:error_message) { "Reset password token is invalid" }
          let(:error_422) { build(:json_api_document, errors: [build(:json_api_error, status: "422", detail: error_message, title: error_message)]) }
          let!(:reset_password_stub) { stub_request(:patch, "#{api_root}/customer_accounts/#{resource_identifier.id}/password_recovery.json_api").with(headers: write_headers, body: reset_password_body).to_return body: error_422.to_h.to_json, status: response_status, headers: default_headers }
          it "should return password_recovery resource with errors" do
            expect(subject).to be_kind_of(::FlexCommerce::PasswordRecovery)
            expect(subject.errors).to be_present
            expect(subject.errors.full_messages).to include(error_message)
          end
        end
      end
    end
    context "authenticating" do
      let(:expected_body) {
        {
            data: {
                type: "customer_account_authentications",
                attributes: {
                    email: resource_identifier.attributes.email,
                    password: resource_identifier.attributes.password
                }
            }
        }.with_indifferent_access
      }
      let(:mock_response_hash) do
        {
          data: {
            type: :customer_account_authentications,
            id: "somelonguid",
            relationships: {
              customer_account: {
                data: {
                  id: "customer-account-1",
                  type: :customer_accounts
                }
              }
            }
          },
          included: [
            {
              id: "customer-account-1",
              type: :customer_accounts,
              attributes: {
                email: resource_identifier.attributes.email
              }
            }
          ]
        }
      end
      context "positive authentication" do
        let(:resource_identifier) { build(:json_api_resource, build_resource: :customer_account_authentication, base_path: base_path) }
        let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }
        before :each do
          stub_request(:post, "#{api_root}/customer_account_authentications.json_api").with(body: expected_body, headers: { "Accept" => "application/vnd.api+json" }).to_return body: mock_response_hash.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.authenticate(email: resource_identifier.attributes.email, password: resource_identifier.attributes.password) }
        it "should return the logged in account" do
          expect(subject.email).to eql resource_identifier.attributes.email
          expect(subject.password).to be_nil
          expect(subject.id).to eql "customer-account-1"
        end
      end
      context "negative authentication" do
        let(:response_status) { 404 }
        let(:error_404) { build(:json_api_document, errors: [build(:json_api_error, status: "404", detail: "Not found", title: "Not found")]) }
        before :each do
          stub_request(:post, "#{api_root}/customer_account_authentications.json_api").with(body: expected_body, headers: { "Accept" => "application/vnd.api+json" }).to_return body: error_404.to_h.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.authenticate(email: resource_identifier.attributes.email, password: resource_identifier.attributes.password) }
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
      it "should provide a paginatable object for the orders results" do
        requests = []
        stub_request(:get, "https://in.elastic.io/hooks/somerandomhook").with(query: hash_including(shopatron_customer_id: "12345", page: {size: "20", number: "2"})).to_return do |request|
          requests << request
          {status: 200, body: {data: [{type: :remote_orders, id: "1", attributes: {}}]}.to_json, headers: {"Content-Type" => "application/vnd.api+json"}}
        end
        expect(subject.orders.page(2).per(20).to_a).to contain_exactly(instance_of(FlexCommerce::RemoteOrder))
        expect(requests.length).to eql 1
      end
    end
  end
end
