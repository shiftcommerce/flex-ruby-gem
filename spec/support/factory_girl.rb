require "factory_girl"
require "faker"
require "ostruct"
require "json"
require "json_struct"


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
FactoryGirl.find_definitions
