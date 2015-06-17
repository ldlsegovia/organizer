class Organizer::Group < Array
  include Organizer::Error

  attr_reader :name, :group_by_attr

  # @param _name [Symbol] symbol to identify this particular group.
  # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
  def initialize(_name, _group_by_attr = nil)
    _group_by_attr = _name if _group_by_attr.blank?
    @name = _name
    @group_by_attr = _group_by_attr
    @group_items = []
  end

  def <<(_item)
    raise_error(:invalid_item) if !_item.is_a?(Organizer::GroupItem)
    super
  end

  # Splits given collection into {Organizer::GroupItem}s based on group_by_attr
  #
  # @param _collection [Organizer::Collection]
  # @return [Organizer::Group] self
  def build(_collection)
    return self if _collection.size.zero?
    if !_collection.first.include_attribute?(self.group_by_attr)
      raise_error(:group_by_attr_not_present_in_collection)
    end

    group_items = _collection.group_by { |item| item.send(self.group_by_attr) }
    group_items.each do |attribute_value_items|
      items = attribute_value_items.last
      group_item = Organizer::GroupItem.new(items)
      self << group_item
    end

    self
  end
end
