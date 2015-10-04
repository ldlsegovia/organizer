module Organizer
  module Collection
    def self.included(_base)
      _base.extend(ClassMethods)
    end

    def <<(_item)
      raise_error(:invalid_item) unless collectable_item?(_item)
      raise_error(:repeated_item) if item_included?(_item.item_name)
      super
    end

    def find_by_name(_name)
      return unless _name
      find { |item| item.has_name?(_name) }
    end

    def select_items(_item_names)
      return [] if empty_item_names?(_item_names)
      select { |item| item_in_names?(item, _item_names) }
    end

    def item_included?(_item_name)
      !!_item_name && select_items([_item_name]).one?
    end

    def reject_items(_item_names)
      return self if empty_item_names?(_item_names)
      reject { |item| item_in_names?(item, _item_names) }
    end

    def collectable_item?(_item)
      self.class.item_classes.include?(_item.class)
    end

    private

    def item_in_names?(_item, _item_names)
      !!_item.item_name &&
        _item_names.map(&:to_sym).include?(_item.item_name.to_sym)
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
