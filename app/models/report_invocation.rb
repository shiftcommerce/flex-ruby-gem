require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Report Invocation model
  #
  # This model provides access to the Shift Report Invocations feature.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #   # List the invocations of the first report
  #   FlexCommerce::Report.first.invocations
  #
  class ReportInvocation < FlexCommerceApi::ApiBase
    has_one :report, class_name: "::FlexCommerce::Report"
  end
end
