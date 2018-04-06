module FlexCommerce
  class SurrogateKeys

    def self.get_keys(key: )
      surrogate_keys = Thread.current[:shift_surrogate_keys]
      return surrogate_keys.join(' ') unless key.nil?
      surrogate_keys = surrogate_keys.nil?  ? "" : surrogate_keys.select { |k| k.include?(key) }.join(' ')
    end

    def self.set_keys(keys)
      if Thread.current[:shift_surrogate_keys]
        Thread.current[:shift_surrogate_keys] += keys
      end
    end

  end
end