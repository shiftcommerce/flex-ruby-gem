# Class: SurrogateKeys
# This class implements the getter and setter methods for surrogate keys
# This is used in 'CartManagement' in rails-site
# 
module FlexCommerce
  class SurrogateKeys

    def self.get_keys(key:)
      # Return all the surrogate keys, if not requested for a particular key
      return surrogate_keys.join(' ') unless key.nil?
      # Select only the surrogate keys, which includes the requested key
      surrogate_keys.nil?  ? "" : surrogate_keys.select { |k| k.include?(key) }.join(' ')
    end

    def self.set_keys(keys)
      # Check if surrogate key is available, then update its value
      if surrogate_keys
        Thread.current[:shift_surrogate_keys] += keys
      end
    end

    def self.surrogate_keys
      Thread.current[:shift_surrogate_keys]
    end

  end
end