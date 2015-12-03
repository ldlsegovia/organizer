module Organizer
  module Operation
    class Simple < Organizer::Operation::Item
      def execute(_item)
        result = definition.call(_item)
        _item.define_attribute(item_name, result)
        mask.execute(_item) if mask
        nil
      end
    end
  end
end
