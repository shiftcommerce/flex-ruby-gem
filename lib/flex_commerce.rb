module FlexCommerce
  def self.gem_root
    File.expand_path("../", __dir__)
  end
  autoload :Product, File.join(gem_root, "app", "models", "product")
  autoload :StaticPage, File.join(gem_root, "app", "models", "static_page")
  autoload :Variant, File.join(gem_root, "app", "models", "variant")
  autoload :MenuItem, File.join(gem_root, "app", "models", "menu_item")
  autoload :Menu, File.join(gem_root, "app", "models", "menu")
  autoload :BreadcrumbItem, File.join(gem_root, "app", "models", "breadcrumb_item")
  autoload :Breadcrumb, File.join(gem_root, "app", "models", "breadcrumb")
end
