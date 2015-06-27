class Organizer::GroupsManager
  include Organizer::Error

  # Creates a new {Organizer::Group} and adds to groups collection.
  #
  # @param _name [Symbol] symbol to identify this particular group.
  # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
  # @return [Organizer::group]
  def add_group(_name, _group_by_attr = nil)
    groups << Organizer::Group.new(_name)
    groups.last
  end

  private

  def groups
    @groups ||= Organizer::GroupsCollection.new
  end
end
