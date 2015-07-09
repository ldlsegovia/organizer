class Organizer::Base
  include Organizer::Error

  def self.inherited(child_class)
    child_class.extend(ChildClassMethods)
    child_class.send(:include, ChildInstanceMethods)
    super
  end

  module ChildClassMethods
    # Persist a proc that needs to return an Array of Hashes.
    #
    # @yield array containing Hash items.
    # @yieldreturn [Array] containing Hash items.
    # @return [void]
    def add_collection(&block)
      @collection_proc = block
      return
    end

    # Adds a default {Organizer::Filter} to {Organizer::FiltersManager}
    #
    # @param _name [optional, Symbol] filter's name.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def add_default_filter(_name = nil, &block)
      filters_manager.add_default_filter(_name, &block)
    end

    # Adds a normal {Organizer::Filter} to {Organizer::FiltersManager}
    #
    # @param _name [Symbol] filter's name.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def add_filter(_name, &block)
      filters_manager.add_normal_filter(_name, &block)
    end

    # Adds a {Organizer::Filter} with value to {Organizer::FiltersManager}
    #
    # @param _name [Symbol] filter's name.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldparam value [Object]
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def add_filter_with_value(_name, &block)
      filters_manager.add_filter_with_value(_name, &block)
    end

    # Adds a new {Organizer::Operation} to {Organizer::OperationsManager}
    #
    # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
    # @yield code that will return the operation's result
    # @yieldparam organizer_item [Organizer::Item]
    # @return [Organizer::Operation]
    def add_operation(_name, &block)
      operations_manager.add_operation(_name, &block)
    end

    # Adds a new {Organizer::GroupOperation} to {Organizer::OperationsManager}
    #
    # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
    # @param _group_name [Symbol] to identify group related with this operation
    # @param _initial_value [Object]
    # @yield code that will return the operation's result
    # @return [Organizer::Operation]
    def add_group_operation(_name, _group_name, _initial_value = 0, &block)
      operations_manager.add_group_operation(_name, _group_name, _initial_value, &block)
    end

    # Adds a new {Organizer::Group} to {Organizer::GroupsManager}
    #
    # @param _name [Symbol] symbol to identify this particular group.
    # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
    # @return [Organizer::Group]
    def add_group(_name, _group_by_attr = nil)
      groups_manager.add_group(_name, _group_by_attr)
    end

    # Returns manager to handle filter issues.
    #
    # @return [Organizer::FiltersManager]
    def filters_manager
      @filters_manager ||= Organizer::FiltersManager.new
    end

    # Returns manager to handle operation issues.
    #
    # @return [Organizer::OperationsManager]
    def operations_manager
      @operations_manager ||= Organizer::OperationsManager.new
    end

    # Returns manager to handle group issues.
    #
    # @return [Organizer::GroupsManager]
    def groups_manager
      @groups_manager ||= Organizer::GroupsManager.new
    end

    # Returns a proc containing an array collection
    #
    # @return [Array]
    def collection_proc
      @collection_proc
    end
  end

  module ChildInstanceMethods
    # @param _collection_options this data will be used to get the desired raw collection. Usually,
    # filters will be passed here.
    def initialize(_collection_options = {})
      @collection_options = _collection_options
    end

    # Applies filters, operations, groups, etc. to defined collection.
    #
    # @param _options [Hash]
    # @return [Organizer::Collection]
    def organize(_options = {})
      result = filters_manager.apply(collection, _options)
      result = operations_manager.execute(result)
      result = groups_manager.build(result, _options)
      operations_manager.execute(result)
    end

    # It returns collection stored as proc in collection_proc var converted to {Organizer::Collection}
    #
    # @return [Organizer::Collection] or [Organizer::Group]
    def collection
      raise_error(:undefined_collection_method) unless collection_proc
      Organizer::Collection.new.fill(collection_proc.call(collection_options))
    end

    private

    def filters_manager; self.class.filters_manager; end
    def operations_manager; self.class.operations_manager; end
    def groups_manager; self.class.groups_manager; end
    def collection_proc; self.class.collection_proc; end
    def collection_options; @collection_options ||= {}; end
  end
end
