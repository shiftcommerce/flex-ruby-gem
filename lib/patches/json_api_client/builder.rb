module JsonApiClient
  module Query
    class Builder
      # Hack which gets around the problem - obviously not the best
      # way to fix this!
      remove_method :last
    end
  end
end
