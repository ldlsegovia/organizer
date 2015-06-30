class Organizer::GroupOperation < Organizer::Operation
  include Organizer::Error

  attr_reader :group_name

  # @param _definition [Proc] contains logic to generate the value for this operation
  # @param _name [Symbol] symbol to identify this particular operation
  # @param _group_name [Symbol] to identify group related with this operation
  def initialize(_definition, _name, _group_name)
    @group_name = _group_name
    super(_definition, _name)
  end

  # Evaluates definition proc to build a new attribute. This attribute will be added to _group_item param.
  #
  # @param _group_item [Organizer::GroupItem] you can use group item's attributes to build the new attribute
  # @return [Organizer::GroupItem] with the new attribute added
  #
  # @raise [Organizer::OperationException] :execute_over_organizer_group_items_only
  def execute(_group_item)
    raise_error(:execute_over_organizer_group_items_only) if !_group_item.is_a?(Organizer::GroupItem)
    _group_item.define_attribute(self.name, 0)
    _group_item.each do |item|
      result = definition.call(_group_item, item)
      _group_item.define_attribute(self.name, result)
    end
  end
end
