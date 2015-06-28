class Organizer::DSL
  include Organizer::Error

  attr_reader :context

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
    @organizer_class = create_organizer_class(_organizer_name)
    @ctx = Organizer::ContextManager.new
    self.instance_eval(&block)
    return
  end

  # Defines a collection in the Organizer class context.
  #
  # @yield array containing Hash items.
  # @yieldreturn [Array] containing Hash items.
  # @return [void]
  #
  # @raise [Organizer::DSLException] :forbidden_nesting
  def collection(&block)
    in_context(block) do
      if @ctx.root_parent?
        @organizer_class.add_collection(&block)
      else
        raise_error(:forbidden_nesting)
      end
    end
  end

  # Adds a default filter to Organizer class.
  # Default filters intend to be applied by default. You will not need to call this filters explicitly.
  #
  # @param _name [optional, Symbol] filter's name.
  # @yield code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item]
  # @yieldreturn [Boolean]
  # @return [Organizer::Filter]
  #
  # @raise [Organizer::DSLException] :forbidden_nesting
  def default_filter(_name = nil, &block)
    in_context(block) do
      if @ctx.root_parent?
        @organizer_class.add_default_filter(_name, &block)
      else
        raise_error(:forbidden_nesting)
      end
    end
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
  #
  # @raise [Organizer::DSLException] :forbidden_nesting
  def filter(_name, &block)
    in_context(block) do
      if @ctx.root_parent?
        accept_value = (block.parameters.count == 2)
        @organizer_class.add_filter(_name, accept_value, &block)
      else
        raise_error(:forbidden_nesting)
      end
    end
  end

  # Adds new opertaion to Organizer class.
  # Operations are calculations that you can perform between collection item attributes.
  #
  # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
  # @yield code that will return the operation's result.
  # @yieldparam organizer_item [Organizer::Item]
  # @return [void]
  #
  # @raise [Organizer::DSLException] :forbidden_nesting
  def operation(_name, &block)
    in_context(block) do
      if @ctx.root_parent?
        @organizer_class.add_operation(_name, &block)
      elsif @ctx.group_parent?
        # TODO: support group operations
      else
        raise_error(:forbidden_nesting)
      end
    end
  end

  # Adds new group to Organizer class.
  # You can group collection items based on attribute param values.
  #
  # @param _name [Symbol] symbol to identify this particular group.
  # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
  # @yield nested definitions.
  # @return [void]
  #
  # @raise [Organizer::DSLException] :forbidden_nesting
  def group(_name, _group_by_attr = nil, &block)
    in_context(block) do
      if @ctx.root_parent?
        @organizer_class.add_group(_name, _group_by_attr)
      elsif @ctx.group_parent?
        # TODO: support nested groups
      else
        raise_error(:forbidden_nesting)
      end
    end
  end

  private

  def in_context(_definition, &action)
    caller_method_name = caller[0][/`.*'/][1..-2]
    @ctx.open(self, caller_method_name, _definition, &action)
    return
  end

  def create_organizer_class(_organizer_name)
    class_name = _organizer_name.to_s.classify
    Object.const_set(class_name, Class.new(Organizer::Base))

  rescue
    raise_error(:invalid_organizer_name)
  end
end
