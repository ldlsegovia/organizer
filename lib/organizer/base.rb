class Organizer::Base
  include Organizer::Error

  def self.inherited(child_class)
    child_class.extend(ChildClassMethods)
    child_class.send(:include, ChildInstanceMethods)
    super
  end

  module ChildClassMethods
    # Defines an instance method named "collection" into an inherited {Organizer::Base} class.
    # After execute MyInheritedClass.collection(){...}, if you execute MyInheritedClass.new.collection
    # you will get a {Organizer::Collection} instance containing many {Organizer::Item} instances as Hash items were
    # passed into the block param.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    # and executed in a new {Organizer::Base} inherited class later.
    #
    # @yield it must return an Array containing Hash items.
    # @raise [Organizer::Exception] :undefined_collection_method
    def collection(&block)
      define_method :collection do
        Organizer::Collection.new.fill(block.call)
      end
    end

    # Adds a new {Organizer::Filter} to default filters collection handled by {Organizer::Filtersmanager}
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @param _name [Symbol]
    # @return [Organizer::Filter]
    #
    # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    def default_filter(_name = nil, &block)
      filters_manager.add_default_filter(_name, &block)
    end

    # Adds a new {Organizer::Filter} to normal filters collection handled by {Organizer::Filtersmanager}
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @param _name [Symbol]
    # @param _accept_value [Symbol] sets true if you want to filter using params
    # @return [Organizer::Filter]
    #
    # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldparam value [Object] with true _accept_value
    # @yieldreturn [Boolean]
    def filter(_name, _accept_value = false, &block)
      if !!_accept_value
        filters_manager.add_filter_with_value(_name, &block)
      else
        filters_manager.add_normal_filter(_name, &block)
      end
    end

    # Adds a new {Organizer::Operation} to operations collection.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
    # @return [Organizer::Operation]
    #
    # @yield you can use the {Organizer::Item} instance param values to build the new attribute value
    # @yieldparam organizer_item [Organizer::Item]
    def operation(_name, &block)
      operations_manager.add_operation(_name, &block)
    end

    # Returns manager to handle default and normal filters
    #
    # @return [Organizer::FiltersManager]
    def filters_manager
      @filters_manager ||= Organizer::FiltersManager.new
    end

    # Returns manager to handle operations
    #
    # @return [Organizer::OperationsManager]
    def operations_manager
      @operations_manager ||= Organizer::OperationsManager.new
    end
  end

  module ChildInstanceMethods
    # Applies default_filters, filters and operations to defined collection.
    # Default filters will be applied automatically.
    # To apply a normal filter, need to pass filter names inside array in _options like this: { enabled_filters: [my_filter] }.
    # To skip a default filter, need to pass default filter names inside array in _options like this: { skip_default_filters: [my_filter] }.
    # If you want to skip all default filters: { skip_default_filters: :all }.
    # To apply filters with values, need to pass filter_key filter_value pairs in _options like this: { my_filter: 4, other_filter: 6 }.
    # Operations will be calculated and added as attributes on each collection item.
    #
    # @param _options [Hash]
    # @return [Organizer::Collection]
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #   MyInheritedClass.organize(enabled_filters: [:my_filter, :other_filter])
    #   MyInheritedClass.organize(skip_default_filters: [:my_filter])
    #   MyInheritedClass.organize(skip_default_filters: :all)
    #   MyInheritedClass.organize(filters: {filter1: 4, filter2: 6})
    def organize(_options = {})
      result = filters_manager.apply(collection, _options)
      operations_manager.execute(result)
    end

    def method_missing(_m, *args, &block)
      raise_error(:undefined_collection_method) if _m == :collection
    end

    private

    def filters_manager
      self.class.filters_manager
    end

    def operations_manager
      self.class.operations_manager
    end
  end
end
