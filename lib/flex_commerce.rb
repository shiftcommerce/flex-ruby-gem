module FlexCommerce
  def self.gem_root
    File.expand_path("../", __dir__)
  end

  # V2 Models
  module V2
    autoload :CreateOrder, File.join(FlexCommerce.gem_root, "app", "models", "v2", "create_order")
    autoload :DeallocateOrder, File.join(FlexCommerce.gem_root, "app", "models", "v2", "deallocate_order")
    autoload :LineItem, File.join(FlexCommerce.gem_root, "app", "models", "v2", "line_item")
    autoload :Order, File.join(FlexCommerce.gem_root, "app", "models", "v2", "order")
    autoload :UnallocateOrder, File.join(FlexCommerce.gem_root, "app", "models", "v2", "unallocate_order")
  end

  # OMS
  module OMS
    autoload :BillingAddress, File.join(FlexCommerce.gem_root, "app", "models", "oms", "billing_address")
    autoload :CustomerOrder, File.join(FlexCommerce.gem_root, "app", "models", "oms", "customer_order")
    autoload :Customer, File.join(FlexCommerce.gem_root, "app", "models", "oms", "customer")
    autoload :Discount, File.join(FlexCommerce.gem_root, "app", "models", "oms", "discount")
    autoload :LineItem, File.join(FlexCommerce.gem_root, "app", "models", "oms", "line_item")
    autoload :Payment, File.join(FlexCommerce.gem_root, "app", "models", "oms", "payment")
    autoload :ShippingAddress, File.join(FlexCommerce.gem_root, "app", "models", "oms", "shipping_address")
    autoload :ShippingMethod, File.join(FlexCommerce.gem_root, "app", "models", "oms", "shipping_method")
  end

  # V1 Models
  autoload :Address, File.join(gem_root, "app", "models", "address")
  autoload :AssetFile, File.join(gem_root, "app", "models", "asset_file")
  autoload :AssetFolder, File.join(gem_root, "app", "models", "asset_folder")
  autoload :Bundle, File.join(gem_root, "app", "models", "bundle")
  autoload :BundleGroup, File.join(gem_root, "app", "models", "bundle_group")
  autoload :Cart, File.join(gem_root, "app", "models", "cart")
  autoload :Category, File.join(gem_root, "app", "models", "category")
  autoload :CategoryTree, File.join(gem_root, "app", "models", "category_tree")
  autoload :Component, File.join(gem_root, "app", "models", "component")
  autoload :ContainerCoupon, File.join(gem_root, "app", "models", "container_coupon")
  autoload :Country, File.join(gem_root, "app", "models", "country")
  autoload :Coupon, File.join(gem_root, "app", "models", "coupon")
  autoload :CustomerAccount, File.join(gem_root, "app", "models", "customer_account")
  autoload :CustomerAccountAuthentication, File.join(gem_root, "app", "models", "customer_account_authentication")
  autoload :CustomerSegment, File.join(gem_root, "app", "models", "customer_segment")
  autoload :CustomerSegmentMember, File.join(gem_root, "app", "models", "customer_segment_member")
  autoload :DataAttribute, File.join(gem_root, "app", "models", "data_attribute")
  autoload :DataStoreRecord, File.join(gem_root, "app", "models", "data_store_record")
  autoload :DataStoreType, File.join(gem_root, "app", "models", "data_store_type")
  autoload :DiscountSummary, File.join(gem_root, "app", "models", "discount_summary")
  autoload :Email, File.join(gem_root, "app", "models", "email")
  autoload :EwisOptIn, File.join(gem_root, "app", "models", "ewis_opt_in")
  autoload :ExternalUrl, File.join(gem_root, "app", "models", "external_url")
  autoload :FreeShippingPromotion, File.join(gem_root, "app", "models", "free_shipping_promotion")
  autoload :Import, File.join(gem_root, "app", "models", "import")
  autoload :ImportEntry, File.join(gem_root, "app", "models", "import_entry")
  autoload :LineItem, File.join(gem_root, "app", "models", "line_item")
  autoload :LineItemDiscount, File.join(gem_root, "app", "models", "line_item_discount")
  autoload :MarkdownPrice, File.join(gem_root, "app", "models", "markdown_price")
  autoload :Menu, File.join(gem_root, "app", "models", "menu")
  autoload :MenuItem, File.join(gem_root, "app", "models", "menu_item")
  autoload :MenuItemItem, File.join(gem_root, "app", "models", "menu_item_item")
  autoload :Note, File.join(gem_root, "app", "models", "note")
  autoload :Order, File.join(gem_root, "app", "models", "order")
  autoload :PasswordRecovery, File.join(gem_root, "app", "models", "password_recovery")
  autoload :PaymentAdditionalInfo, File.join(gem_root, "app", "models", "payment_additional_info")
  autoload :PaymentAddressVerification, File.join(gem_root, "app", "models", "payment_address_verification")
  autoload :PaymentProcess, File.join(gem_root, "app", "models", "payment_process")
  autoload :PaymentProvider, File.join(gem_root, "app", "models", "payment_provider")
  autoload :PaymentProviderSetup, File.join(gem_root, "app", "models", "payment_provider_setup")
  autoload :PaymentTransaction, File.join(gem_root, "app", "models", "payment_transaction")
  autoload :PriceEntry, File.join(gem_root, "app", "models", "price_entry")
  autoload :Product, File.join(gem_root, "app", "models", "product")
  autoload :ProductAssetFile, File.join(gem_root, "app", "models", "product_asset_file")
  autoload :Promotion, File.join(gem_root, "app", "models", "promotion")
  autoload :PromotionQualifyingProductExclusion, File.join(gem_root, "app", "models", "promotion_qualifying_product_exclusion")
  autoload :Redirect, File.join(gem_root, "app", "models", "redirect")
  autoload :Refund, File.join(gem_root, "app", "models", "refund")
  autoload :RemoteAddress, File.join(gem_root, "app", "models", "remote_address")
  autoload :RemoteLineItem, File.join(gem_root, "app", "models", "remote_line_item")
  autoload :RemoteOrder, File.join(gem_root, "app", "models", "remote_order")
  autoload :RemoteShippingMethod, File.join(gem_root, "app", "models", "remote_shipping_method")
  autoload :Role, File.join(gem_root, "app", "models", "role")
  autoload :Report, File.join(gem_root, "app", "models", "report")
  autoload :ReportInvocation, File.join(gem_root, "app", "models", "report_invocation")
  autoload :RetailStore, File.join(gem_root, "app", "models", "retail_store")
  autoload :SearchSuggestion, File.join(gem_root, "app", "models", "search_suggestion")
  autoload :Section, File.join(gem_root, "app", "models", "section")
  autoload :Session, File.join(gem_root, "app", "models", "session")
  autoload :ShippingMethod, File.join(gem_root, "app", "models", "shipping_method")
  autoload :Slug, File.join(gem_root, "app", "models", "slug")
  autoload :StaticPage, File.join(gem_root, "app", "models", "static_page")
  autoload :StaticPageFolder, File.join(gem_root, "app", "models", "static_page_folder")
  autoload :StockLevel, File.join(gem_root, "app", "models", "stock_level")
  autoload :TaxCode, File.join(gem_root, "app", "models", "tax_code")
  autoload :Taxonomy, File.join(gem_root, "app", "models", "taxonomy")
  autoload :Template, File.join(gem_root, "app", "models", "template")
  autoload :TemplateComponent, File.join(gem_root, "app", "models", "template_component")
  autoload :TemplateDefinition, File.join(gem_root, "app", "models", "template_definition")
  autoload :TemplateSection, File.join(gem_root, "app", "models", "template_section")
  autoload :UnallocateOrder, File.join(gem_root, "app", "models", "unallocate_order")
  autoload :User, File.join(gem_root, "app", "models", "user")
  autoload :UserProfile, File.join(gem_root, "app", "models", "user_profile")
  autoload :Variant, File.join(gem_root, "app", "models", "variant")
  autoload :Webhook, File.join(gem_root, "app", "models", "webhook")

  # Services
  autoload :ParamToShql, File.join(gem_root, "app", "services", "param_to_shql")
  autoload :SurrogateKeys, File.join(gem_root, "app", "services", "surrogate_keys")
  autoload :PaypalExpress, File.join(gem_root, "lib", "paypal_express")
  autoload :Retry, File.join(gem_root, "lib", "retry")
end
