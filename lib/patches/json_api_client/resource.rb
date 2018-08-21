require "json_api_client/version"
if ["1.5.3"].include?(JsonApiClient::VERSION)
  require "json_api_client/resource"
  module JsonApiClient
    class Resource
      def save
        return false unless valid?

        self.last_result_set = if persisted?
          self.class.requestor.update(self)
        else
          self.class.requestor.create(self)
        end

        if last_result_set.has_errors?
          fill_errors
          false
        else
          self.errors.clear if self.errors
          mark_as_persisted!
          if updated = last_result_set.first
            self.attributes = updated.attributes
            self.links.attributes = updated.links.attributes
            self.relationships.attributes = updated.relationships.attributes
            clear_changes_information
            # This line has been added as part of https://github.com/JsonApiClient/json_api_client/pull/285
            self.relationships.clear_changes_information
          end
          true
        end
      end
    end
  end
else
  raise %q(
    Please check this PR:
      * https://github.com/JsonApiClient/json_api_client/pull/285 (This hasn't yet been released at the time of writing this)

    If both have been merged into the gem version you are using, remove this file (#{__FILE__}).
    If not, add the current version to the allowed array at the top of this file.
  )
end
