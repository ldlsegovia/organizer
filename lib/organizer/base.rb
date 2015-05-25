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
    # @raise [Organizer::Exception] :undefined_collection_method, :invalid_collection_structure and
    #   :invalid_collection_item_structure
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #
    #   MyInheritedClass.collection do
    #     [
    #       { attr1: 4, attr2: "Hi" },
    #       { attr1: 6, attr2: "Ciao" },
    #       { attr1: 84, attr2: "Hola" }
    #    ]
    #   end
    #
    #   MyInheritedClass.new.collection
    #   #=> [#<Organizer::Item:0x007fe6a09b2010 @attr1=4, @attr2="Hi">, #<Organizer::Item...
    def collection(&block)
      define_method :collection do
        raw_collection = block.call
        validate_raw_collection(raw_collection)
        get_organized_items(raw_collection)
      end
    end

    # Creates a {Organizer::Filter} based on block param and adds this new filter to default_filters collection.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    # @raise [Organizer::FilterException] :definition_must_be_a_proc
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #
    #   MyInheritedClass.default_filter do |organizer_item|
    #     organizer_item.attr1 == organizer_item.attr2
    #   end
    def default_filter(_name = nil, &block)
      filter = Organizer::Filter.new(block, _name)
      default_filters << filter
    end

    # Returns default filters collection added using {Organizer::Base::ChildClassMethods#default_filter} method.
    #
    # @return [Organizer::FiltersCollection]
    def default_filters
      @default_filters ||= Organizer::FiltersCollection.new
    end

    # Creates a {Organizer::Filter} based on block param and adds this new filter to filters collection.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @param _name [Symbol]
    #
    # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
    # @yieldparam organizer_item [Organizer::Item]
    # @yieldreturn [Boolean]
    # @raise [Organizer::FilterException] :definition_must_be_a_proc
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #
    #   MyInheritedClass.filter(:my_filter) do |organizer_item|
    #     organizer_item.attr1 == organizer_item.attr2
    #   end
    def filter(_name, &block)
      filter = Organizer::Filter.new(block, _name)
      filters << filter
    end

    # Returns filters collection added using {Organizer::Base::ChildClassMethods#filter} method.
    #
    # @return [Organizer::FiltersCollection]
    def filters
      @filters ||= Organizer::FiltersCollection.new
    end

    # Creates an {Organizer::Operation} based on block param and adds this new operation to operations collection.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    #
    # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
    #
    # @yield you can use the {Organizer::Item} instance param values to build the new attribute value
    # @yieldparam organizer_item [Organizer::Item]
    # @raise [Organizer::OperationException] :definition_must_be_a_proc and :blank_name
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #
    #   MyInheritedClass.operation do |organizer_item|
    #     organizer_item.attr1 + organizer_item.attr2
    #   end
    def operation(_name, &block)
      organizer_operation = Organizer::Operation.new(block, _name)
      operations << organizer_operation
    end

    # Returns operations collection added using {Organizer::Base::ChildClassMethods#operation} method.
    #
    # @return [Organizer::OperationsCollection]
    def operations
      @operations ||= Organizer::OperationsCollection.new
    end
  end

  module ChildInstanceMethods

    # Applies default_filters, filters and operations to defined collection.
    # Default filters will be applied automatically.
    # To apply a normal filter, need to pass filter names inside array in _options like this: { filters: [my_filter] }.
    # Operations will be calculated and added as attributes on each collection item.
    #
    # @example
    #   class MyInheritedClass < Organizer::Base; end
    #
    #   MyInheritedClass.organize(filters: [:my_filter, :other_filter])
    #
    # @param _options [Hash]
    # @return [Organizer::Collection]
    def organize(_options = {})
      result = collection
      result = apply_default_fitlers(result)
      result = apply_normal_filters(_options, result)
      result = execute_operations(result)
      result
    end

    def method_missing(_m, *args, &block)
      raise_error(:undefined_collection_method) if _m == :collection
    end

    private

    def execute_operations(_collection)
      return _collection if operations.count <= 0
      _collection.each do |item|
        operations.each do |operation|
          operation.execute(item)
        end
      end
    end

    def apply_default_fitlers(_collection)
      apply_filters(default_filters, _collection)
    end

    def apply_normal_filters(_options, _collection)
      filter_names = _options.fetch(:filters, [])
      selected_filters = select_filters(filter_names)
      apply_filters(selected_filters, _collection)
    end

    def apply_filters(_filters, _collection)
      return _collection if _filters.count <= 0
      _collection.reject do |item|
        reject_item = false
        _filters.each do |filter|
          if !filter.apply(item)
            reject_item = true
            break
          end
        end
        reject_item
      end
    end

    def default_filters
      self.class.default_filters
    end

    def filters
      self.class.filters
    end

    def operations
      self.class.operations
    end

    def select_filters(_filter_names)
      filters.select { |filter| _filter_names.include?(filter.name) }
    end

    def validate_raw_collection(_raw_collection)
      raise_error(:invalid_collection_structure) unless _raw_collection.is_a?(Array)

      if _raw_collection.count > 0 && !_raw_collection.first.is_a?(Hash)
        raise_error(:invalid_collection_item_structure)
      end
    end

    def get_organized_items(_raw_collection)
      _raw_collection.inject(Organizer::Collection.new) do |items, raw_item|
        items << build_organized_item(raw_item)
      end
    end

    def build_organized_item(_raw_item)
      item = Organizer::Item.new
      item.define_attributes(_raw_item)
    end
  end

end
