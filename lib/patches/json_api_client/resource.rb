if ["0.6.27"].include?(FlexCommerceApi::VERSION)
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
          last_result_set.errors.each do |error|
            if error.source_parameter
              errors.add(error.source_parameter, error.title || error.detail)
            else
              errors.add(:base, error.title || error.detail)
            end
          end
          false
        else
          self.errors.clear if self.errors
          mark_as_persisted!
          if updated = last_result_set.first
            self.attributes = updated.attributes
            self.links.attributes = updated.links.attributes
            self.relationships.attributes = updated.relationships.attributes
            clear_changes_information
          end
          true
        end
      end
    end
  end
else
  raise "Please check this PR (https://github.com/chingor13/json_api_client/pull/238) and if it has been merged, remove this file (#{__FILE__}) - if not add the current version to the allowed array at the top of this file."
end
