# frozen_string_literal: true
module Retry

  DEFAULT_MAX_NO_OF_RETRIES = 2
  DEFAULT_RESCUE_ERRORS = StandardError

  def self.call(no_of_retries: DEFAULT_MAX_NO_OF_RETRIES, rescue_errors: DEFAULT_RESCUE_ERRORS, &blk)
    total_attempts = 0
    begin
      blk.call
    rescue rescue_errors => ex
      total_attempts += 1 
      retry if total_attempts < no_of_retries
    ensure
      if total_attempts == no_of_retries
        return
      end
    end
  end
end
