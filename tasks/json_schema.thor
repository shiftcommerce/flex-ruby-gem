require "json"
require "active_support/core_ext/string"
class JsonSchema < Thor
  desc "generate_from_vcr", "Given a json encoded vcr file, produces a json schema compatible schema."

  def generate_from_vcr(output_file, input_file, thing = output_file)
    interaction = JSON.parse(File.read(input_file))["http_interactions"].first
    data = interaction.dig("response", "body", "decoded")
    node = data["data"] # This will be different for a collection
    version = get_version_from_uri(interaction.dig("request", "uri"))
    base_dir = File.expand_path("../schemas/shift/#{version}", File.dirname(__FILE__))

    generate_resource_schema(node, File.join(base_dir, "resources", output_file), thing)
    generate_collection_document_schema(data, File.join(base_dir, "documents", "collection", output_file), thing)
    generate_member_document_schema(data, File.join(base_dir, "documents", "member", output_file), thing)
  end

  private

  def generate_collection_document_schema(data, full_filename, thing)
    schema = {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "type": "object",
      properties: {
        data: {
          type: "array",
          items: {
            "$ref": "#/definitions/resource"
          }
        },
        meta: {
          type: "object",
          additionalProperties: true
        },
        jsonapi: {
          type: "object"
        },
        links: {
          type: "object"
        },
        included: {
          type: "array",
          items: {
            "$ref": "#/definitions/includedItems"
          }
        }
      },
      required: ["data", "meta"],
      additionalProperties: false,
      definitions: {
        resource: {"$ref": "../../resources/#{File.basename(full_filename)}"},
        includedItems: {
          oneOf: detect_used_items_in_included_data(data)
        }
      }
    }
    FileUtils.mkdir_p(File.dirname(full_filename))
    File.open(full_filename, "w") { |file| file.write(JSON.pretty_generate(schema).to_s) }
  end

  def detect_used_items_in_included_data(data)
    return [] unless data.key?("included")
    data["included"].map do |node|
      {
        "$ref": "../../resources/#{node["type"].singularize}.json"
      }
    end
  end

  def generate_member_document_schema(data, full_filename, thing)
    schema = {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "type": "object",
      properties: {
        data: {
          type: "object",
          "$ref": "#/definitions/resource"
        },
        meta: {
          type: "object",
          additionalProperties: true
        },
        jsonapi: {
          type: "object"
        },
        links: {
          type: "object"
        },
        included: {
          type: "array",
          items: {
            "$ref": "#/definitions/includedItems"
          }
        }
      },
      additionalProperties: false,
      definitions: {
        resource: {"$ref": "../../resources/#{File.basename(full_filename)}"},
        includedItems: {
          oneOf: detect_used_items_in_included_data(data)
        }
      }
    }
    FileUtils.mkdir_p(File.dirname(full_filename))
    File.open(full_filename, "w") { |file| file.write(JSON.pretty_generate(schema).to_s) }
  end

  def generate_resource_schema(node, full_filename, thing)
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
          "pattern": "^#{node["type"]}$"
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

    FileUtils.mkdir_p(File.dirname(full_filename))
    File.open(full_filename, "w") { |file| file.write(JSON.pretty_generate(schema).to_s) }
  end

  def get_version_from_uri(uri)
    URI.parse(uri).path.split("/").reject { |node| node == "" }[1]
  end

  def properties_for_attributes(node)
    node["attributes"].reduce({}) do |acc, (attribute, value)|
      acc.merge attribute => guess_type_def_for(attribute, value)
    end
  end

  def properties_for_relationships(node)
    return {} if node["relationships"].nil?
    node["relationships"].reduce({}) do |acc, (relationship, definition)|
      acc.merge relationship => {
        type: "object",
        properties: {
          "links": {
            "type": "object",
            "properties": {
              "self": {
                "type": "string"
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
