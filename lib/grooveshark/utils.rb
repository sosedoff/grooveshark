class String
  def normalize_attribute
    self.gsub(/^.*::/, "").
         gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
         gsub(/([a-z\d])([A-Z])/,'\1_\2').
         downcase
  end
end

class Hash
  def normalize
    h = {}
    self.each_pair do |k,v|
      attr = k.to_s.normalize_attribute
      case v
        when Hash
          h[attr] = v.normalize
        when Array
          h[attr] = v.map { |o| o.kind_of?(Hash) ? o.normalize : o }
        else
          h[attr] = v
      end
    end
    h
  end
end