module FlexCommerce
  def self.gem_root
    File.expand_path("../", __dir__)
  end
  autoload :Product, File.join(gem_root, "app", "models", "product")
end
