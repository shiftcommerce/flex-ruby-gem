require 'dotenv'
Dotenv.load

RSpec.shared_context "server context" do
  def setup_for_api!
    FlexCommerceApi.config do |config|
      config.flex_root_url = ENV.fetch("API_ROOT", "http://api.shiftlocal.co.uk:3000")
      config.flex_api_key = ENV.fetch("API_KEY", "314e47ece578a11e6e77c6153229cd25")
      config.flex_account = ENV.fetch("API_ACCOUNT", "testing")
      config.logger = nil
      #config.logger = ActiveSupport::Logger.new(STDOUT)
    end
    WebMock.allow_net_connect!
  end
  def teardown_for_api!
    WebMock.disable_net_connect!
  end
  before(:each) do
    setup_for_api!
  end
  after(:each) do
    teardown_for_api!
  end

end

RSpec.shared_context "server crud context" do

end
