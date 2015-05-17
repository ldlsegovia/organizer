class OrganizerBase
  include Organizer::Error

  # Defines a privated instance method named "collection". After execute OrganizerBase.collection, if you
  # execute OrganizerBase.new.send(:collection) (instance) you will get an OrganizedCollection instance
  # containing many OrganizedItem instances as Hash items were passed into the block param.
  # It's no intended to use this method directly on the OrganizerBase class. This method will be used
  # inside {Organizer.define} block and executed in a new OrganizerBase child class.
  #
  # @yield it must return an Array containing Hash items.
  # @raise [Organizer::Exception] :undefined_collection_method, :invalid_collection_structure and
  #   :invalid_collection_item_structure
  #
  # @example
  #   OrganizerBase.collection do
  #     [
  #       { attr1: 4, attr2: "Hi"},
  #       { attr1: 6, attr2: "Ciao" },
  #       { attr1: 84, attr2: "Hola" }
  #    ]
  #   end
  #
  #   OrganizerBase.new.send(:collection).class
  #   #=> OrganizedCollection
  #   OrganizerBase.new.send(:collection)
  #   #=> [#<OrganizedItem:0x007fe6a09b2010 @attr1=4, @attr2="Hi">, #<OrganizedItem...
  def self.collection(&block)
    define_method :collection do
      raw_collection = block.call
      validate_raw_collection(raw_collection)
      get_organized_items(raw_collection)
    end

    private :collection
  end

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
    _raw_collection.inject(OrganizedCollection.new) do |items, raw_item|
      items << build_organized_item(raw_item)
    end
  end

  def build_organized_item(_raw_item)
    item = OrganizedItem.new
    item.define_attributes(_raw_item)
  end

end
