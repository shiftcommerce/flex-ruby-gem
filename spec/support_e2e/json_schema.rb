require "json-schema"
require "oj"

RSpec::Matchers.define :be_valid_json_for_schema do |schema_name|
  match do |response|
    @body = response.respond_to?(:body) ? response.body : response
    schema_path = File.expand_path("../../schemas/#{schema_name}", File.dirname(__FILE__))

    @errors = []
    # Don't use 'strict: true' since it has side-effect making all properties required.
    # Use 'additionalProperties: false' in schema instead.
    begin
      # Use 'validate_schema: true' in addition to above so json-schema gem loads all schemas from its cache
      @errors += JSON::Validator.fully_validate(schema_path, @body, strict: false, validate_schema: true)
    rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError => error
      @errors << error
    end
    @errors.empty?
  end

  failure_message do
    [
      "Validating body with #{schema_name} returned errors.",
      "Errors:\n#{@errors.join("\n")}",
      "Body:\n#{@body}"
    ].join("\n\n")
  end
end
