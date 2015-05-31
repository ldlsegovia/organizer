class Organizer::Base
  include Organizer::Error

  def self.inherited(child_class)
    child_class.extend(ChildClassMethods)
    child_class.send(:include, ChildInstanceMethods)
    super
  end

  module ChildClassMethods
    # Defines an instance method named "collection" into an inherited {Organizer::Base} class.
    #   After execute MyInheritedClass.collection(){...}, if you execute MyInheritedClass.new.collection
    #   you will get a {Organizer::Collection} instance.
    #
    # @yield array containing Hash items.
    # @yieldreturn [Array] containing Hash items.
    # @return [void]
    def collection(&block)
      define_method(:collection) { Organizer::Collection.new.fill(block.call) }
      return
    end

    # Adds a default {Organizer::Filter} to {Organizer::FiltersManager}
    #
    # @param _name [optional, Symbol] filter's name.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def default_filter(_name = nil, &block)
      filters_manager.add_default_filter(_name, &block)
    end

    # Adds a normal {Organizer::Filter} to {Organizer::FiltersManager}
    #
    # @param _name [Symbol] filter's name.
    # @param _accept_value [Symbol] sets true if you want to filter using params.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldparam value [Object] if _accept_value is true
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def filter(_name, _accept_value = false, &block)
      if !!_accept_value
        filters_manager.add_filter_with_value(_name, &block)
      else
        filters_manager.add_normal_filter(_name, &block)
      end
    end

    # Adds a new {Organizer::Operation} to {Organizer::OperationsManager}
    #
    # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
    # @yield code that will return the operation's result
    # @yieldparam organizer_item [Organizer::Item]
    # @return [Organizer::Operation]
    def operation(_name, &block)
      operations_manager.add_operation(_name, &block)
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
  end

  module ChildInstanceMethods
    # Applies default_filters, filters and operations to the defined collection.
    #   Default filters will be applied automatically.
    #   To apply a normal filter, need to pass filter names inside array in _options like this:
    #   { enabled_filters: [my_filter] }.
    #   To skip a default filter, need to pass default filter names inside array in _options like this:
    #   { skip_default_filters: [my_filter] }.
    #   If you want to skip all default filters: { skip_default_filters: :all }.
    #   To apply filters with params, need to pass filter_key filter_value pairs in _options like this:
    #   { my_filter: 4, other_filter: 6 }.
    #   Operations will be calculated and added as attributes on each collection item.
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
