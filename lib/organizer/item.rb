class Organizer::Item
  include Organizer::Error

  # Creates attribute readers based on _hash keys. A reader's value will be the hash value of that key.
  # It's no intended to use this method directly. Organizer::Item's will be created executing the "collection"
  # instance method defined by the {Organizer::Base::ChildClassMethods#collection} class method.
  #
  # @param _hash [Hash]
  # @return [Organizer::Item] self
  #
  # @raise [Organizer::ItemException] :must_be_a_hash, :invalid_attribute_key and
  #   :method_redefinition_not_allowed
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
  #   i = Organizer::Item.new
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

  def define_attribute(_attr_name, _value)
    method_name = method_name_from_string(_attr_name)
    define_attr_reader(method_name, _value)
    self
  end

  private

  def method_name_from_string(_string)
    raise_error(:invalid_attribute_key) if !_string.match(/^[A-z0-9\-\s]+$/)
    method_name = _string.to_s.underscore.gsub(" ", "_")
    raise_error(:method_redefinition_not_allowed) if self.respond_to?(method_name)
    method_name
  end

  def define_attr_reader(_method_name, _value)
    self.singleton_class.send(:attr_reader, _method_name)
    self.instance_variable_set("@#{_method_name}", _value)
  end
end
