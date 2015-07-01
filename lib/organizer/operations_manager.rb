class Organizer::OperationsManager
  include Organizer::Error

  # Creates a new {Organizer::Operation} and adds to operations collection.
  #
  # @param _name [Symbol] operation's name
  # @yield contains logic to generate the result for this particular operation.
  # @yieldparam organizer_item [Organizer::Item] you can use item's attributes to get the desired operation result.
  # @return [Organizer::Operation]
  def add_operation(_name, &block)
    operations << Organizer::Operation.new(block, _name)
    operations.last
  end

  # Creates a new {Organizer::GroupOperation} and adds to group operations collection.
  #
  # @param _name [Symbol] operation's name
  # @param _group_name [Symbol] to identify group related with this operation
  # @yield contains logic to generate the result for this particular operation.
  # @return [Organizer::Operation]
  def add_group_operation(_name, _group_name, &block)
    group_operations << Organizer::GroupOperation.new(block, _name, _group_name)
    group_operations.last
  end

  # Each collection's items will be evaluated against all defined operations. The operation's results
  # will be attached to items as new attributes.
  #
  # @param _collection [Organizer::Collection] or [Organizer::Group]
  # @return [Organizer::Collection] or [Organizer::Group] the collection with new attributes attached.
  #
  # @raise [Organizer::OperationsManagerException]
  def execute(_collection)
    current_operations = _collection.is_a?(Organizer::Group) ? group_operations : operations
    return _collection if current_operations.count <= 0
    _collection.each { |item| execute_recursively(item, current_operations.dup) }
    _collection
  end

  private

  def execute_recursively(_item, _operations, _previous_operations_count = 0)
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
      execute_recursively(_item, _non_executed_operations, _previous_operations_count)
    end
  end

  def operations
    @operations ||= Organizer::OperationsCollection.new
  end

  def group_operations
    @group_operations ||= Organizer::OperationsCollection.new
  end
end
