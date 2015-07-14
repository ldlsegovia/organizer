module Organizer
  module Operation
    class SourceItem < Organizer::Operation::Item
      # Evaluates definition proc to build a new attribute. This attribute will be added to _item param.
      #
      # @param _item [Organizer::Source::Item] you can use item's attributes to build the new attribute
      # @return [Organizer::Source::Item] with the new attribute added
      #
      # @raise [Organizer::Operation::SourceItemException] :execute_over_organizer_items_only
      #
      # @example
      #   hash = { attr1: 400, attr2: 266 }
      #   item = Organizer::Source::Item.new
      #   item.define_attributes(hash)
      #
      #   proc = Proc.new do |organizer_item|
      #     organizer_item.attr1 + organizer_item.attr2
      #   end
      #
      #   item = Organizer::Operation::SourceItem.new(proc, :attrs_sum).execute(item)
      #   item.attrs_sum
      #   #=> 666
      def execute(_item)
        raise_error(:execute_over_organizer_items_only) if !_item.is_a?(Organizer::Source::Item)
        result = definition.call(_item)
        _item.define_attribute(self.name, result)
      end
    end
  end
end
