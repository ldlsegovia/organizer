class OrganizedCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_organizer_collection_item) if !_item.is_a?(OrganizedItem)
    super
  end
end
