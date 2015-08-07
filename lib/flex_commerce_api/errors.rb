module FlexCommerceApi
  module Error
    autoload :InternalServer, File.expand_path(File.join("error", "internal_server"), __dir__)
    autoload :UnexpectedStatus, File.expand_path(File.join("error", "unexpected_status"), __dir__)
    autoload :NotFound, File.expand_path(File.join("error", "not_found"), __dir__)
    autoload :AccessDenied, File.expand_path(File.join("error", "access_denied"), __dir__)
  end
end