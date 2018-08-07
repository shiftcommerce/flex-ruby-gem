# This module extends json_api_client's ParseJson service
# to make sure malformed repsonse bodies is always included as context in
# the thrown error message when json parsing fails.
module FlexCommerceApi
  module JsonApiClientExtension
    module ParseJson
      def call(environment)
        super
      rescue JSON::ParserError => error
        error.define_singleton_method(:raven_context) do
          {
            extra: {
              body: environment.body
            }  
          }
        end
        raise
      end
    end
  end
end

JsonApiClient::Middleware::ParseJson.send :prepend, FlexCommerceApi::JsonApiClientExtension::ParseJson
