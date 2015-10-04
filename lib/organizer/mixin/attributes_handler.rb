module Organizer
  module AttributesHandler
    def define_attributes(_hash)
      raise_error(:must_be_a_hash) unless _hash.is_a?(Hash)
      _hash.each { |attr_name, value| define_attribute(attr_name, value) }
      self
    end

    def define_attribute(_attr_name, _value, read_only = true)
      method_name = method_name_from_string(_attr_name)
      raise_error(:attr_already_defined) if self.respond_to?(method_name)
      accessor_type = !!read_only ? :attr_reader : :attr_accessor
      singleton_class.send(accessor_type, method_name)
      instance_variable_set("@#{method_name}", _value)
      attribute_names << method_name.to_sym
      self
    end

    def attribute_names
      @attribute_names ||= []
    end

    def include_attribute?(_attribute_name)
      attribute_names.include?(_attribute_name)
    end

    def clone_attributes(_obj)
      if !_obj.class.included_modules.include?(Organizer::AttributesHandler)
        raise_error(:attributes_handler_not_included)
      end

      _obj.attribute_names.each do |_attribute_name|
        define_attribute(_attribute_name, _obj.send(_attribute_name))
      end

      nil
    end

    private

    def method_name_from_string(_string)
      raise_error(:invalid_attribute_key) if !_string.match(/^[A-z0-9\-\s]+$/)
      _string.to_s.underscore.tr(" ", "_")
    end
  end
end
