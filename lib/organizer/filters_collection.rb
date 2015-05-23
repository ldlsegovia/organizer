class Organizer::FiltersCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_filter_collection_item) if !_item.is_a?(Organizer::Filter)
    super
  end
end
