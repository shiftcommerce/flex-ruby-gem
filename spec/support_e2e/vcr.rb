require 'vcr'
require 'jrjackson'
module JrJacksonSerializer
  class << self
    # The file extension to use for this serializer.
    #
    # @return [String] "json"
    def file_extension
      "json"
    end

    # Serializes the given hash.
    #
    # @param [Hash] hash the object to serialize
    # @return [String] the JSON string
    def serialize(hash)
      hash["http_interactions"].map! do |i|
        i["response"]["body"]["decoded"] = JrJackson::Json.load(i["response"]["body"]["string"]) rescue JrJackson::ParseError
        i
      end
      JSON.pretty_generate(hash)
    end

    # Deserializes the given string using `MultiJson`.
    #
    # @param [String] string the JSON string
    # @return [Hash] the deserialized object
    def deserialize(string)
      JrJackson::Json.load(string)
    end
  end
end
VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { record: :all, erb: false, serialize_with: :jrjackson }
  c.cassette_library_dir = 'spec/recordings'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.cassette_serializers[:jrjackson] = JrJacksonSerializer
end