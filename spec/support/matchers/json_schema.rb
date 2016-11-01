require "json-schema"
require "jrjackson"

RSpec::Matchers.define :be_valid_json_for_schema do |schema_name|
  match do |response|
    @body = response.respond_to?(:body) ? response.body : response
    schema_path = File.expand_path(File.join("..", "..", "schemas", "#{schema_name}.schema.json"), __dir__)
    obj = { "$ref" => schema_path.to_s }
    @errors = JSON::Validator.fully_validate(JrJackson::Json.dump(obj), @body, strict: true)
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
