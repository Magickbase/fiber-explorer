class CkbUtils
  def self.hash_value_to_s(hash)
    hash.each do |key, value|
      next if !!value == value

      if value.is_a?(Hash)
        hash_value_to_s(value)
      elsif value.is_a?(Array)
        hash[key] = value
      else
        hash[key] = value.to_s
      end
    end
  end
end
