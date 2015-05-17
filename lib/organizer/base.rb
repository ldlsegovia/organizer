class Organizer::Base
  include Organizer::Error

  def self.inherited(child_class)
    child_class.extend(ChildClassMethods)
    child_class.send(:include, ChildInstanceMethods)
    super
  end

  module ChildClassMethods
    # Defines a private instance method named "collection" into an inherited Organizer::Base class.
    # After execute MyInheritedClass.collection(){...}, if you execute MyInheritedClass.new.send(:collection)
    # you will get an Organizer::Collection instance containing many Organizer::Item instances as Hash items were
    # passed into the block param.
    # It's no intended to use this method directly. This method will be used inside {Organizer::Template.define} block
    # and executed in a new Organizer::Base inherited class later.
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
    #   MyInheritedClass.new.send(:collection)
    #   #=> [#<Organizer::Item:0x007fe6a09b2010 @attr1=4, @attr2="Hi">, #<Organizer::Item...
    def collection(&block)
      define_method :collection do
        raw_collection = block.call
        validate_raw_collection(raw_collection)
        get_organized_items(raw_collection)
      end

      private :collection
    end
  end

  module ChildInstanceMethods
    def method_missing(_m, *args, &block)
      raise_error(:undefined_collection_method) if _m == :collection
    end

    private

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
