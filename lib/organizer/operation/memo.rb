module Organizer
  module Operation
    class Memo < Organizer::Operation::Item
      attr_reader :initial_value

      def initialize(_definition, _name, _initial_value = 0)
        @initial_value = _initial_value
        super(_definition, _name)
      end

      def execute(_memo_item, _item)
        if !_memo_item.respond_to?(item_name)
          _memo_item.define_attribute(item_name, initial_value, false)
        end

        result = definition.call(_memo_item, _item)
        _memo_item.send("#{item_name}=", result)
        nil
      end
    end
  end
end
