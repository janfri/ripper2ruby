require 'ruby/assoc'

module Ruby
  class Hash < DelimitedList
    def [](key)
      each { |assoc| return assoc.value if assoc.key.value == key } or nil
    end
    
    def []=(key, value)
      value = from_native(value, nil, ' ') unless value.is_a?(Node)
      if assoc = detect { |assoc| assoc.key.value == key }
        assoc.value = value
      else
        # # TODO never happens, fix positions
        # separators << Token.new(',')
        # elements << Assoc.new(key, value)
        # self[key]
      end
    end
    
    def delete(key)
      delete_if { |assoc| assoc.key.value == key }
    end
    
    def value
      code = to_ruby(false)
      code = "{#{code}}" unless code =~ /^\s*{/
      eval(code) rescue {}
    end
  end
end