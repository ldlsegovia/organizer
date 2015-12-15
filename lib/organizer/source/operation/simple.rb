module Organizer
  module Source
    module Operation
      class Item < Organizer::Operation::Item
        def execute(_item)
          result = definition.call(_item)
          _item.define_attribute(item_name, result)
          mask.execute(_item) if mask
          nil
        end
      end
    end
  end
end
