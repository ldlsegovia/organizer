class Organizer::GroupsCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_item) if !_item.is_a?(Organizer::Group)
    super
  end

  # Find group by name
  #
  # param _name [Symbol] group's name
  # @return [Organizer::Group]
  def group_by_name _name
    return unless _name
    self.find { |group| group.has_name?(_name) }
  end
end
