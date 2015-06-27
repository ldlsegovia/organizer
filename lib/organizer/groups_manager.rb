class Organizer::GroupsManager
  include Organizer::Error

  # Creates a new {Organizer::Group} and adds to groups collection.
  #
  # @param _name [Symbol] symbol to identify this particular group.
  # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
  # @return [Organizer::group]
  def add_group(_name, _group_by_attr = nil)
    groups << Organizer::Group.new(_name, _group_by_attr)
    groups.last
  end

  # Searches the group named as { group_by: :my_group } in _options. If group is found, it groups
  # collection items according the group definition.
  #
  # @param _collection [Organizer::Collection]
  # @param _options [Hash]
  # @return [Organizer::Group] or [Organizer::Collection] when group is not found
  #
  # @raise [Organizer::OperationsManagerException]
  def build(_collection, _options)
    group_name = _options.fetch(:group_by, nil)
    return _collection unless group_name
    group = groups.group_by_name(group_name)
    return _collection unless group
    group.build(_collection)
  end

  private

  def groups
    @groups ||= Organizer::GroupsCollection.new
  end
end
