# Class: SurrogateKeys
# This class implements the getter and setter methods for surrogate keys
# This is used in 'CartManagement' in rails-site
#
module FlexCommerce
  class SurrogateKeys
    # Returns the filtered external surrogate keys from api response,
    # if no filter value is set, it will return all keys
    #
    # ===== Examples
    #     Thread.current[:shift_surrogate_keys] = ["matalanb%2Fcarts", "matalanb%2Fshipping_methods", "matalanb%2Fpromotion_shipping_methods"]
    #
    #     FlexCommerce::SurrogateKeys.keys(filter: 'cart')
    #       # => ["matalanb%2Fcarts"]
    #     FlexCommerce::SurrogateKeys.keys
    #       # => ["matalanb%2Fcarts", "matalanb%2Fshipping_methods", "matalanb%2Fpromotion_shipping_methods"]

    def self.keys(filter: nil)
      surrogate_keys = Thread.current[:shift_surrogate_keys]
      # Return all the surrogate keys, if not requested for a particular key
      return surrogate_keys if filter.nil?
      # Select only the surrogate keys, which includes the requested key
      surrogate_keys.nil? ? [] : surrogate_keys.select { |k| k.include?(filter) }
    end

    # Appends the keys to the Thread shift_surrogate_keys variable.
    #
    # ==== Examples
    #     Thread.current[:shift_surrogate_keys] = ["matalanb%2Fcarts", "matalanb%2Fcart%2F31719184"]
    #     keys = ["matalanb%2Fcarts", "matalanb%2Fcart%2F31719184"]
    #
    #     FlexCommerce::SurrogateKeys.append_keys(keys)
    #         # => ["matalanb%2Fcarts", "matalanb%2Fcart%2F31719184", "matalanb%2Fcarts", "matalanb%2Fcart%2F31719184"]
    #
    def self.append_keys(*keys)
      # Check if surrogate key is available, if not initiate it
      Thread.current[:shift_surrogate_keys] ||= []
      Thread.current[:shift_surrogate_keys] += keys.flatten
      Thread.current[:shift_surrogate_keys] = Thread.current[:shift_surrogate_keys].uniq
    end
  end
end
