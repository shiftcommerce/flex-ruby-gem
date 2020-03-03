require "json_api_client"
Dir.glob(File.expand_path("../patches/**/*.rb", __FILE__)).each do |file|
  require file
end
