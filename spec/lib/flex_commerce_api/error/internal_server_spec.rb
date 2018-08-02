require "spec_helper"

describe FlexCommerceApi::Error::InternalServer do
  describe "message" do
    it "extracts the error message for a string string body" do
      response = {body: "oops!"}
      internal_server_error = described_class.new(nil, response)
      expect(internal_server_error.message).to eq "Internal server error - oops!"
    end

    it "extracts the error message from the 'message' field when given" do
      response = {
        body: {
          "message" => "oops!"
        }
      }
      internal_server_error = described_class.new(nil, response)
      expect(internal_server_error.message).to eq "Internal server error - oops!"
    end

    it "extracts the error message for an errors hash" do
      response = {
        body: {
          "errors" => [
            "title" => "Oops!",
            "detail" => "I have no idea what I am doing!",
            "meta" => {
              "exception" => "Exception details",
              "backtrace" => "Exception backtrace",
              "event_id" => "123"
            }
          ]
        }
      }
      internal_server_error = described_class.new(nil, response)
      expect(internal_server_error.message).to eq "Internal server error - Oops! I have no idea what I am doing! 123 Exception details Exception backtrace"
    end

    it "does not return an error message when there isn't one" do
      response = {}
      internal_server_error = described_class.new(nil, response)
      expect(internal_server_error.message).to eq "Internal server error"
    end

  end
end
