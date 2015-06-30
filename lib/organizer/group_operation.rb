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
end
