class Organizer::Collection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_item) if !_item.is_a?(Organizer::Item)
    super
  end

  # Loads this collection instance with {Organizer::Item}s created from _raw_rollection param.
  #
  # @param _raw_collection [Array] it must return an Array containing Hash items.
  # @return [Organizer::Collection]
  #
  # @raise [Organizer::CollectionException] :invalid_collection_structure and
  #   :invalid_collection_item_structure
  def fill(_raw_rollection)
    validate_raw_collection(_raw_rollection)
    get_organized_items(_raw_rollection)
  end

  private

  def validate_raw_collection(_raw_collection)
    raise_error(:invalid_collection_structure) unless _raw_collection.is_a?(Array)

    if _raw_collection.count > 0 && !_raw_collection.first.is_a?(Hash)
      raise_error(:invalid_collection_item_structure)
    end
  end

  def get_organized_items(_raw_collection)
    _raw_collection.inject(self) do |items, raw_item|
      items << build_organized_item(raw_item)
    end
  end

  def build_organized_item(_raw_item)
    item = Organizer::Item.new
    item.define_attributes(_raw_item)
  end
end
