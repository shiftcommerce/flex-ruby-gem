# Class: SurrogateKeys
# This class implements the getter and setter methods for surrogate keys
# This is used in 'CartManagement' in rails-site
# 
module FlexCommerce
  class SurrogateKeys

    def self.keys(filter: nil)
      surrogate_keys = Thread.current[:shift_surrogate_keys]
      # Return all the surrogate keys, if not requested for a particular key
      return surrogate_keys if filter.nil?
      # Select only the surrogate keys, which includes the requested key
      surrogate_keys.nil?  ? [] : surrogate_keys.select { |k| k.include?(filter) }
    end

    def self.append_keys(*keys)
      # Check if surrogate key is available, then update its value
      Thread.current[:shift_surrogate_keys] ||= []
      Thread.current[:shift_surrogate_keys] += keys.flatten
    end

  end
end