module FlexCommerce
  def self.gem_root
    File.expand_path("../", __dir__)
  end

  # Models
  autoload :Product, File.join(gem_root, "app", "models", "product")
  autoload :ProductAssetFile, File.join(gem_root, "app", "models", "product_asset_file")
  autoload :StaticPage, File.join(gem_root, "app", "models", "static_page")
  autoload :StaticPageFolder, File.join(gem_root, "app", "models", "static_page_folder")
  autoload :Variant, File.join(gem_root, "app", "models", "variant")
  autoload :EwisOptIn, File.join(gem_root, "app", "models", "ewis_opt_in")
  autoload :MenuItem, File.join(gem_root, "app", "models", "menu_item")
  autoload :MenuItemItem, File.join(gem_root, "app", "models", "menu_item_item")
  autoload :Menu, File.join(gem_root, "app", "models", "menu")
  autoload :BreadcrumbItem, File.join(gem_root, "app", "models", "breadcrumb_item")
  autoload :Breadcrumb, File.join(gem_root, "app", "models", "breadcrumb")
  autoload :Category, File.join(gem_root, "app", "models", "category")
  autoload :CategoryTree, File.join(gem_root, "app", "models", "category_tree")
  autoload :Cart, File.join(gem_root, "app", "models", "cart")
  autoload :Coupon, File.join(gem_root, "app", "models", "coupon")
  autoload :ContainerCoupon, File.join(gem_root, "app", "models", "container_coupon")
  autoload :DiscountSummary, File.join(gem_root, "app", "models", "discount_summary")
  autoload :FreeShippingPromotion, File.join(gem_root, "app", "models", "free_shipping_promotion")
  autoload :LineItem, File.join(gem_root, "app", "models", "line_item")
  autoload :RemoteLineItem, File.join(gem_root, "app", "models", "remote_line_item")
  autoload :LineItemDiscount, File.join(gem_root, "app", "models", "line_item_discount")
  autoload :CustomerAccount, File.join(gem_root, "app", "models", "customer_account")
  autoload :CustomerAccountAuthentication, File.join(gem_root, "app", "models", "customer_account_authentication")
  autoload :Address, File.join(gem_root, "app", "models", "address")
  autoload :RemoteAddress, File.join(gem_root, "app", "models", "remote_address")
  autoload :ShippingMethod, File.join(gem_root, "app", "models", "shipping_method")
  autoload :RemoteShippingMethod, File.join(gem_root, "app", "models", "remote_shipping_method")
  autoload :Order, File.join(gem_root, "app", "models", "order")
  autoload :RemoteOrder, File.join(gem_root, "app", "models", "remote_order")
  autoload :PaymentTransaction, File.join(gem_root, "app", "models", "payment_transaction")
  autoload :PaymentAddressVerification, File.join(gem_root, "app", "models", "payment_address_verification")
  autoload :PaymentAdditionalInfo, File.join(gem_root, "app", "models", "payment_additional_info")
  autoload :PaymentTransactionAuth, File.join(gem_root, "app", "models", "payment_transaction_auth")
  autoload :PaymentTransactionSettle, File.join(gem_root, "app", "models", "payment_transaction_settle")
  autoload :PaymentTransactionVoid, File.join(gem_root, "app", "models", "payment_transaction_void")
  autoload :PaymentProvider, File.join(gem_root, "app", "models", "payment_provider")
  autoload :PaymentProviderSetup, File.join(gem_root, "app", "models", "payment_provider_setup")
  autoload :TemplateDefinition, File.join(gem_root, "app", "models", "template_definition")
  autoload :TemplateSection, File.join(gem_root, "app", "models", "template_section")
  autoload :TemplateComponent, File.join(gem_root, "app", "models", "template_component")
  autoload :Template, File.join(gem_root, "app", "models", "template")
  autoload :Section, File.join(gem_root, "app", "models", "section")
  autoload :Component, File.join(gem_root, "app", "models", "component")
  autoload :SearchSuggestion, File.join(gem_root, "app", "models", "search_suggestion")
  autoload :AssetFile, File.join(gem_root, "app", "models", "asset_file")
  autoload :AssetFolder, File.join(gem_root, "app", "models", "asset_folder")
  autoload :Country, File.join(gem_root, "app", "models", "country")
  autoload :Promotion, File.join(gem_root, "app", "models", "promotion")
  autoload :StockLevel, File.join(gem_root, "app", "models", "stock_level")
  autoload :BundleGroup, File.join(gem_root, "app", "models", "bundle_group")
  autoload :Refund, File.join(gem_root, "app", "models", "refund")
  autoload :RetailStore, File.join(gem_root, "app", "models", "retail_store")
  autoload :Redirect, File.join(gem_root, "app", "models", "redirect")
  autoload :Report, File.join(gem_root, "app", "models", "report")
  autoload :ReportInvocation, File.join(gem_root, "app", "models", "report_invocation")
  autoload :Webhook, File.join(gem_root, "app", "models", "webhook")
  autoload :Bundle, File.join(gem_root, "app", "models", "bundle")
  autoload :User, File.join(gem_root, "app", "models", "user")
  autoload :Role, File.join(gem_root, "app", "models", "role")
  autoload :UserProfile, File.join(gem_root, "app", "models", "user_profile")
  autoload :Email, File.join(gem_root, "app", "models", "email")
  autoload :MarkdownPrice, File.join(gem_root, "app", "models", "markdown_price")
  autoload :CustomerSegment, File.join(gem_root, "app", "models", "customer_segment")
  autoload :Session, File.join(gem_root, "app", "models", "session")
  autoload :DataStoreRecord, File.join(gem_root, "app", "models", "data_store_record")
  autoload :DataStoreType, File.join(gem_root, "app", "models", "data_store_type")
  autoload :DataAttribute, File.join(gem_root, "app", "models", "data_attribute")
  autoload :Note, File.join(gem_root, "app", "models", "note")
  autoload :PasswordRecovery, File.join(gem_root, "app", "models", "password_recovery")
  autoload :Slug, File.join(gem_root, "app", "models", "slug")

  # Services
  autoload :ParamToShql, File.join(gem_root, "app", "services", "param_to_shql")
end
