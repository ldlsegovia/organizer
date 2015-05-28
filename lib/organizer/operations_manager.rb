class Organizer::OperationsManager
  include Organizer::Error

  # Creates a new {Organizer::Operation} and adds to operations collection.
  #
  # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
  # @return [Organizer::Operation]
  #
  # @yield you can use the {Organizer::Item} instance param values to build the new attribute value
  # @yieldparam organizer_item [Organizer::Item]
  def add_operation(_name = nil, &block)
    operations << Organizer::Operation.new(block, _name)
    operations.last
  end

  # For each collection's item and operation, it creates a new attribute (inside item) with the operation's result.
  #
  # @param _collection [Organizer::Collection] the whole collection
  # @return [Organizer::Collection]
  def execute(_collection)
    return _collection if operations.count <= 0
    _collection.each do |item|
      operations.each do |operation|
        operation.execute(item)
      end
    end
    _collection
  end

  private

  def operations
    @operations ||= Organizer::OperationsCollection.new
  end
end
