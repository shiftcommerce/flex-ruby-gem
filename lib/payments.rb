Dir.glob(File.expand_path("../payments/**/*.rb", __FILE__)).each do |file|
  require file
end