class Organizer::OperationsCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_item) if !_item.is_a?(Organizer::Operation)
    super
  end

  # Builds a string containing operation errors
  #
  # @return [String]
  def get_errors
    self.select {|o| o.has_error? }.map {|operation| operation.error.message }.join(', ')
  end
end
