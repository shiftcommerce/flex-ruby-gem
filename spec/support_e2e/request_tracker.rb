module Shift
  module Test
    module RequestTracker
      def http_request_tracker
        Thread.current[:http_request_tracker]
      end
    end
  end
end

RSpec.configure do |config|
  Thread.current[:http_request_tracker] = []
  config.before(:suite) do
    WebMock.after_request real_requests_only: true do |request, response|
      Thread.current[:http_request_tracker] << {request: request, response: response}
    end
  end
  config.before(:each) do |example|
    Thread.current[:http_request_tracker].clear
  end
  config.include Shift::Test::RequestTracker
end
