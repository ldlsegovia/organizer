class Organizer::OperationsCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_operations_collection_item) if !_item.is_a?(Organizer::Operation)
    super
  end
end
