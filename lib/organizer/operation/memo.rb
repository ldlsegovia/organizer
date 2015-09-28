module Organizer
  module Operation
    class Memo < Organizer::Operation::Item
      attr_reader :initial_value

      # @param _definition [Proc] contains logic to generate the value for this operation
      # @param _name [Symbol] symbol to identify this particular operation
      # @param _initial_value [Object]
      def initialize(_definition, _name, _initial_value = 0)
        @initial_value = _initial_value
        super(_definition, _name)
      end

      # Evaluates definition proc to build a new attribute. This attribute will be added to _item.
      #
      # @param _memo_item [Object] attribute holding the accumulated result
      # @param _item [Object] needs to include [Organizer::AttributesHandler] mixin
      # @return [void]
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
