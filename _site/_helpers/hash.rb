class Hash
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