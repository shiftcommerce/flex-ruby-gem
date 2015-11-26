module FlexCommerceApi
  module Error
    autoload :Base, File.expand_path(File.join("error", "base"), __dir__)
    autoload :ClientError, File.expand_path(File.join("error", "client_error"), __dir__)
    autoload :ConnectionError, File.expand_path(File.join("error", "connection_error"), __dir__)
    autoload :InternalServer, File.expand_path(File.join("error", "internal_server"), __dir__)
    autoload :UnexpectedStatus, File.expand_path(File.join("error", "unexpected_status"), __dir__)
    autoload :NotFound, File.expand_path(File.join("error", "not_found"), __dir__)
    autoload :AccessDenied, File.expand_path(File.join("error", "access_denied"), __dir__)
    autoload :RecordInvalid, File.expand_path(File.join("error", "record_invalid"), __dir__)
  end
end