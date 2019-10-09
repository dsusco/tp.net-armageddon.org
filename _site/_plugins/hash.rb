class Hash
  def deep_reference(key)
    self.reduce(self[key]) { |value, (k, v)|
      v.is_a?(Hash) ? ((value + v.deep_reference(key)) rescue v.deep_reference(key)) : value
    }
  end

  def dig_assignment(*keys, value)
    last_key = keys.pop
    hash = keys.reduce(self) { |hash, key| hash[key].nil? ? hash[key] = {} : hash[key] }

    hash.has_key?(last_key) ? hash[last_key] += value : hash[last_key] = value
  end

  def recursively_stringify_keys
    self.inject({}) do |result, (key, value)|
      result[key.to_s] = (value.is_a?(Hash) ? value.stringify_keys : value)

      result
    end
  end

  def recursively_symbolize_keys
    self.inject({}) do |result, (key, value)|
      result[key.to_sym] = (value.is_a?(Hash) ? value.symbolize_keys : value)

      result
    end
  end

  def stringify_keys
    self.inject({}) do |result, (key, value)|
      result[key.to_s] = value

      result
    end
  end

  def symbolize_keys
    self.inject({}) do |result, (key, value)|
      result[key.to_sym] = value

      result
    end
  end
end