require "json"
class JsonSchema < Thor
  desc "generate_from_vcr", "Given a json encoded vcr file, produces a json schema compatible schema."
  def generate_from_vcr(output_file, input_file, thing = output_file)
    o = JSON.parse(File.read(input_file))
    i = o["http_interactions"].first
    data = i.dig("response", "body", "decoded")
    node = data["data"] # This will be different for a collection
    schema = {
        "$schema": "http://json-schema.org/draft-04/schema#",
        "type": "object",
        "properties": {
            "id": {
                "type": "string",
                "description": "A unique identifier for the #{thing}"
            },
            "type": {
                "type": "string",
                "description": "The json_api type for any #{thing}",
                "format": "^#{node["type"]}$"
            },
            "attributes": {
                "type": "object",
                "properties": properties_for_attributes(node)
            },
            "relationships": {
                "type": "object",
                "properties": properties_for_relationships(node)
            },
            "links": {
                "type": "object",
                "properties": {
                    "self": {
                        "type": "string"
                    }
                },
                "additionalProperties": false
            },
            "meta": {
                "type": "object",
                "additionalProperties": false
            }
        },
        "definitions": {

        }
    }

    version = get_version_from_uri(i.dig("request", "uri"))
    base_dir = File.expand_path("../schemas/shift/#{version}/resources", File.dirname(__FILE__))
    full_filename = File.join(base_dir, output_file)
    FileUtils.mkdir_p(File.dirname(full_filename))
    File.open(full_filename, "w") {|file| file.write("#{JSON.pretty_generate(schema)}")}
  end

  private

  def get_version_from_uri(uri)
    URI.parse(uri).path.split("/").reject {|node| node==""}[1]
  end
  def properties_for_attributes(node)
    node["attributes"].reduce({}) do |acc, (attribute, value)|
      acc.merge attribute => guess_type_def_for(attribute, value)
    end
  end

  def properties_for_relationships(node)
    node["relationships"].reduce({}) do |acc, (relationship, definition)|
      acc.merge relationship => {
          "links": {
              "type": "object",
              "properties": {
                  "self": {
                      "type": "string",
                  },
                  "related": {
                      "type": "string"
                  }
              },
              "additionalProperties": false
          },
          "data": guess_data_type_for_relationship(relationship, definition),
          "meta": {
              "type": "object",
              "additionalProperties": true
          }
      }
    end
  end

  def guess_type_def_for(attribute, value)
    case value
      when TrueClass, FalseClass
        {
            "type": "boolean",
            "description": "Description for #{attribute}"
        }
      when Numeric
        {
            "type": "number",
            "description": "Description for #{attribute}"
        }
      when Hash
        {
            "type": "object",
            "description": "Description for #{attribute}"
        }
      when NilClass
        {
            "type": "null",
            "description": "Description for #{attribute}"
        }
      when Array
        {
            "type": "array",
            "description": "Description for #{attribute}"
        }
      when String
        {
            "type": "string",
            "description": "Description for #{attribute}"
        }
      else
        raise "Type #{value.class.name} unknown"
    end
  end

  def guess_data_type_for_relationship(relationship, definition)
    if definition.key?("data")
      definition["data"].is_a?(Array) ? array_relationship_data : singular_relationship_data
    else
      {
          "oneOf": [
              singular_relationship_data,
              array_relationship_data
          ]
      }
    end
  end

  def array_relationship_data
    {
        "type": "array",
        "items": {
            "type": "object",
            "description": "The id and type form a pointer into the 'included' top level document property",
            "properties": {
                "id": {
                    "type": "string"
                },
                "type": {
                    "type": "string"
                }
            },
            "additionalProperties": false
        }
    }
  end

  def singular_relationship_data
    {
        "type": "object",
        "description": "The id and type form a pointer into the 'included' top level document property",
        "properties": {
            "id": {
                "type": "string"
            },
            "type": {
                "type": "string"
            }
        },
        "additionalProperties": false
    }
  end
end