module Organizer::AttributesHandler
  attr_reader :attribute_names

  # Creates attribute readers based on _hash keys. A reader's value will be the hash value of that key.
  #
  # @param _hash [Hash]
  # @return self
  #
  # @raise [Organizer::ItemException] :must_be_a_hash and :invalid_attribute_key
  #
  # @example
  #   hash = {
  #     "withCamelCase" => "Hi!",
  #     "with-hypen-characters" => "Bye!",
  #     "UPPERCASE_CHARACTERS" => false,
  #     "spaces   are   allowed" => 4,
  #     "underscore_characters" => 6,
  #     "num3r1c_ch4r4ct3rs" => true,
  #   }
  #
  #   i = MyClass.new # class that includes Organizer::AttributesHandler module
  #   i.define_attributes(hash)
  #   i.with_camel_case #=> "Hi!"
  #   i.with_hypen_characters #=> "Bye!"
  #   i.uppercase_characters #=> false
  #   i.spaces___are___allowed #=> 4
  #   i.underscore_characters #=> 6
  #   i.num3r1c_ch4r4ct3rs #=> true
  def define_attributes(_hash)
    raise_error(:must_be_a_hash) unless _hash.is_a?(Hash)
    _hash.each { |attr_name, value| define_attribute(attr_name, value) }
    self
  end

  # Creates an attribute reader containing the _value variable.
  #
  # @param _attr_name [Symbol] this will be the reader's mehtod name
  # @param _value [Object] this will be the reader's return value
  # @return self
  def define_attribute(_attr_name, _value)
    method_name = method_name_from_string(_attr_name)
    define_attr_reader(method_name, _value)
    self
  end

  # Returns defined attribute names for the class that includes this module
  #
  # @return [Array]
  def attribute_names
    @attribute_names ||= []
  end

  # Checks if class has attribute passed as param
  #
  # @param _attribute_name [Symbol]
  # @return [Boolean]
  def include_attribute?(_attribute_name)
    self.attribute_names.include?(_attribute_name)
  end

  # It copies attribute readers from _obj param
  #
  # @param _obj [Object] any object including Organizer::AttributesHandler module
  # @return [void]
  def clone_attributes(_obj)
    if !_obj.class.included_modules.include?(Organizer::AttributesHandler)
      raise_error(:attributes_handler_not_included)
    end

    _obj.attribute_names.each do |_attribute_name|
      self.define_attribute(_attribute_name, _obj.send(_attribute_name))
    end

    return
  end

  private

  def method_name_from_string(_string)
    raise_error(:invalid_attribute_key) if !_string.match(/^[A-z0-9\-\s]+$/)
    _string.to_s.underscore.gsub(" ", "_")
  end

  def define_attr_reader(_method_name, _value)
    self.singleton_class.send(:attr_reader, _method_name)
    self.instance_variable_set("@#{_method_name}", _value)
    attribute_names << _method_name.to_sym
  end
end