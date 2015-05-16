class OrganizedItem
  include Organizer::Error

  def define_attributes(_hash)
    raise_error(:organized_item_must_be_a_hash) unless _hash.is_a?(Hash)

    _hash.each do |attr_name, value|
      method_name = method_name_from_string(attr_name)
      define_attr_reader(method_name, value)
    end

    self
  end

  private

  def method_name_from_string(_string)
    if !_string.match(/^[A-z0-9\-\s]+$/)
      raise_error(:invalid_organized_item_attribute)
    end

    method_name = _string.to_s.underscore.gsub(" ", "_")

    if self.respond_to?(method_name)
      raise_error(:method_redefinition_not_allowed)
    end

    method_name
  end

  def define_attr_reader(_method_name, _value)
    self.singleton_class.send(:attr_reader, _method_name)
    self.instance_variable_set("@#{_method_name}", _value)
  end
end
