module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Source::Operation::Item, Organizer::Group::Operation::ParentItem

      def add_simple_item(_name, _options = {}, &block)
        self << Organizer::Source::Operation::Item.new(block, _name, _options)
        last
      end

      def add_mask_item(_attribute, _mask, _options = {})
        self << Organizer::Operation::MaskBuilder.build(_attribute, _mask, _options)
        last
      end

      def add_group_parent_item(_name, _initial_value = 0, _options = {}, &block)
        self << Organizer::Group::Operation::ParentItem.new(block, _name, _initial_value, _options)
        last
      end

      def get_errors
        select(&:has_error?).map { |operation| operation.error.message }.join(', ')
      end
    end
  end
end
