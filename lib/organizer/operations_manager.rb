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
  #
  # @raise [Organizer::OperationsManagerException]
  def execute(_collection)
    return _collection if operations.count <= 0
    _collection.each { |item| execute_on_item(item, operations.dup) }
    _collection
  end

  private

  def execute_on_item(_item, _operations, _previous_operations_count = 0)
    return _item if _operations.size.zero?

    if _previous_operations_count == _operations.size
      raise_error(_operations.get_errors)
    end

    _non_executed_operations = Organizer::OperationsCollection.new
    _previous_operations_count = _operations.size

    _operations.each do |operation|
      begin
        operation.execute(_item)
      rescue Exception => e
        operation.error = e
        _non_executed_operations << operation
      end
    end

    if _non_executed_operations.size > 0
      execute_on_item(_item, _non_executed_operations, _previous_operations_count)
    end
  end

  def operations
    @operations ||= Organizer::OperationsCollection.new
  end
end
