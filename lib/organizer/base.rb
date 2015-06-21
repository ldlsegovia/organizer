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
    # @param _accept_value [Symbol] sets true if you want to filter using params.
    # @yield code that must return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldparam value [Object] if _accept_value is true
    # @yieldreturn [Boolean]
    # @return [Organizer::Filter]
    def add_filter(_name, _accept_value = false, &block)
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
    def add_operation(_name, &block)
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

    # Returns a proc containing an array collection
    #
    # @return [Array]
    def collection_proc
      @collection_proc
    end
  end

  module ChildInstanceMethods
    # @param _collection_options this data will be used to get the desired raw collection. Usually,
    #   filters will be passed here.
    def initialize(_collection_options = {})
      @collection_options = _collection_options
    end

    # Applies default_filters, filters and operations to defined collection.
    #   Default filters will be applied automatically.
    #   To apply a normal filter, need to pass filter names inside array in _options like this:
    #   { enabled_filters: [my_filter] }.
    #   To skip a default filter, need to pass default filter names inside array in _options like this:
    #   { skip_default_filters: [my_filter] }.
    #   If you want to skip all default filters: { skip_default_filters: :all }.
    #   To apply filters with params, need to pass filter_key filter_value pairs in _options like this:
    #   { filters: { my_filter: 4, other_filter: 6 } }.
    #   You can apply autogenerated filters too. For example: { filters: { my_attr_eq: 4, my_attr_gt: 6 } }
    #   if your items has "my_attr" attribute.
    #
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

    # It returns collection stored as proc in collection_proc var converted to {Organizer::Collection}
    #
    # @return [Organizer::Collection]
    def collection
      raise_error(:undefined_collection_method) unless collection_proc
      Organizer::Collection.new.fill(collection_proc.call(collection_options))
    end

    private

    def filters_manager
      self.class.filters_manager
    end

    def operations_manager
      self.class.operations_manager
    end

    def collection_proc
      self.class.collection_proc
    end

    def collection_options
      @collection_options ||= {}
    end
  end
end
