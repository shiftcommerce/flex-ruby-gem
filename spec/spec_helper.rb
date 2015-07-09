require "webmock/rspec"
# include supporting files from spec/support
root = File.expand_path("../", __dir__)
Dir[File.join root, "spec/support/**/*.rb"].sort.each { |f| require f }
