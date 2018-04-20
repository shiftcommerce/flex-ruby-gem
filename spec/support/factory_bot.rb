require "factory_bot"
require "faker"
require "ostruct"
require "json"
require "json_struct"
require "json_erb"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
FactoryBot.find_definitions
