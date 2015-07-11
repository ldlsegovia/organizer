module Organizer
  module Collection
    def self.included(_base)
      _base.extend(ClassMethods)
    end

    def <<(_item)
      raise_error(:invalid_item) unless self.class.item_classes.include?(_item.class)
      super
    end

    # Find collection item by name
    #
    # param _name [Symbol] item's name
    # @return [Object] collectable object
    def find_by_name _name
      return unless _name
      self.find { |item| item.has_name?(_name) }
    end

    # Returns items included into _item_names array
    #
    # param _item_names [Array] item names to select
    # @return [Object] the filtered collection
    def select_items(_item_names)
      return [] if empty_item_names?(_item_names)
      self.select { |item| item_in_names?(item, _item_names) }
    end

    # Returns all items except ones included into _item_names array
    #
    # param _item_names [Array] item names to exlcude
    # @return [Object]
    def reject_items(_item_names)
      return self if empty_item_names?(_item_names)
      self.reject { |item| item_in_names?(item, _item_names) }
    end

    private

    def item_in_names?(_item, _item_names)
      !!_item.name && _item_names.map(&:to_sym).include?(_item.name.to_sym)
    end

    def empty_item_names?(_item_names)
      !_item_names.is_a?(Array) || _item_names.count <= 0
    end

    module ClassMethods
      def collectable_classes(*_collectable_classes)
        @item_classes = _collectable_classes
      end

      def item_classes
        @item_classes || raise("must set collectable item class")
      end
    end
  end
end
