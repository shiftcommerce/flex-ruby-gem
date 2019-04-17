module JsonApiClient
    module Query
      class Builder
        # This is a workaround because in the json_api_client gem they now parse
        # the "last" link instead of the original behaviour:
        # https://github.com/JsonApiClient/json_api_client/blob/v1.5.3/lib/json_api_client/query/builder.rb#L69
        # This causes an error when Faraday parses our params due to the filter
        # param appearing to be malformed.
        #
        # TODO: Look at fixing our links so that we can remove this workaround
        # (platform ticket #7293)
        def last
          self.to_a.last
        end
      end
    end
  end