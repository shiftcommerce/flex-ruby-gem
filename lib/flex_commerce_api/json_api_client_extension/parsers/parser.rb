require_relative "../included_data"

module FlexCommerceApi
  module JsonApiClientExtension
    module Parsers
      class Parser < ::JsonApiClient::Parsers::Parser
        class << self
          def handle_included(result_set, data)
            result_set.included = ::FlexCommerceApi::JsonApiClientExtension::IncludedData.new(result_set, data.fetch("included", []))
          end
        end
      end
    end

  end
end
