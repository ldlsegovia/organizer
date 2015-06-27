class Organizer::DSL
  include Organizer::Error

  attr_accessor :organizer_class

  # Creates a class that inherits from {Organizer::Base}.
  #   Inside the block, you can execute the DSL's instance methods in order to customize the new
  #   inherited class behaviour.
  #
  # @param _organizer_name [String] the name of the new {Organizer::Base} inherited class.
  # @yield you need to pass Organizer::DSL instance methods inside the block
  # @return [void]
  #
  # @raise [Organizer::DSLException] :invalid_organizer_name
  def initialize(_organizer_name, &block)
    self.organizer_class = create_organizer_class(_organizer_name)
    self.instance_eval(&block)
    return
  end

  # Defines a collection in the Organizer class context.
  #
  # @yield array containing Hash items.
  # @yieldreturn [Array] containing Hash items.
  # @return [void]
  def collection(&block)
    organizer_class.add_collection(&block)
    return
  end

  # Adds a default filter to Organizer class.
  # Default filters intend to be applied by default. You will not need to call this filters explicitly.
  #
  # @param _name [optional, Symbol] filter's name.
  # @yield code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item]
  # @yieldreturn [Boolean]
  # @return [Organizer::Filter]
  def default_filter(_name = nil, &block)
    organizer_class.add_default_filter(_name, &block)
    return
  end

  # Adds a normal filter to to Organizer class.
  # This kind of filters need to be called explicitly using filters name.
  #
  # @param _name [Symbol] filter's name.
  # @yield code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item]
  # @yieldparam value [Object] if you want to pass paramentes
  # @yieldreturn [Boolean]
  # @return [void]
  def filter(_name, &block)
    accept_value = (block.parameters.count == 2)
    organizer_class.add_filter(_name, accept_value, &block)
    return
  end

  # Adds new opertaion to Organizer class.
  # Operations are calculations that you can perform between collection item attributes.
  #
  # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
  # @yield code that will return the operation's result.
  # @yieldparam organizer_item [Organizer::Item]
  # @return [void]
  def operation(_name, &block)
    organizer_class.add_operation(_name, &block)
    return
  end

  # Adds new group to Organizer class.
  # You can group collection items based on attribute param values.
  #
  # @param _name [Symbol] symbol to identify this particular group.
  # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
  # @return [void]
  def group(_name, _group_by_attr = nil)
    organizer_class.add_group(_name, _group_by_attr)
    return
  end

  private

  def create_organizer_class(_organizer_name)
    class_name = _organizer_name.to_s.classify
    Object.const_set(class_name, Class.new(Organizer::Base))

  rescue
    raise_error(:invalid_organizer_name)
  end
end
