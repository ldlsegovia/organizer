class OrganizerBase
  include Organizer::Error

  def self.collection(&block)
    define_method :collection do
      raw_collection = block.call
      validate_raw_collection(raw_collection)
      get_organized_items(raw_collection)
    end

    private :collection
  end

  def method_missing(_m, *args, &block)
    raise_error(:undefined_collection_method) if _m == :collection
  end

  private

  def validate_raw_collection(_raw_collection)
    raise_error(:invalid_collection_structure) unless _raw_collection.is_a?(Array)

    if _raw_collection.count > 0 && !_raw_collection.first.is_a?(Hash)
      raise_error(:invalid_collection_item_structure)
    end
  end

  def get_organized_items(_raw_collection)
    _raw_collection.inject(OrganizedCollection.new) do |items, raw_item|
      items << build_organized_item(raw_item)
    end
  end

  def build_organized_item(_raw_item)
    item = OrganizedItem.new
    item.define_attributes(_raw_item)
  end

end
