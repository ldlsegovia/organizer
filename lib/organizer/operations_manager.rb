class Organizer::OperationsManager
  include Organizer::Error

  # Creates a new {Organizer::Operation} and adds to operations collection.
  #
  # @param _name [Symbol] operation's name
  # @yield contains logic to generate the result for this particular operation.
  # @yieldparam organizer_item [Organizer::Item] you can use item's attributes to get
  #   the desired operation result.
  # @return [Organizer::Operation]
  def add_operation(_name = nil, &block)
    operations << Organizer::Operation.new(block, _name)
    operations.last
  end

  # Each collection's items will be evaluated against all defined operations. The operation's results
  #  will be attached to items as new attributes.
  #
  # @param _collection [Organizer::Collection]
  # @return [Organizer::Collection] the collection with new attributes attached.
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
