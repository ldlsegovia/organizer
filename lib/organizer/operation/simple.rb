module Organizer
  module Operation
    class Simple < Organizer::Operation::Item
      # Evaluates definition proc to build a new attribute. This attribute will be added to _item.
      #
      # @param _item [Object] needs to include [Organizer::AttributesHandler] mixin
      # @return [Object] with the new attribute added
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
      #   item = Organizer::Operation::Simple.new(proc, :attrs_sum).execute(item)
      #   item.attrs_sum
      #   #=> 666
      def execute(_item)
        result = definition.call(_item)
        _item.define_attribute(item_name, result)
        nil
      end
    end
  end
end
