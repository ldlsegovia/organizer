module Organizer
  module Group
    module Operation
      class ParentItem < Organizer::Operation::Item
        attr_reader :initial_value

        def initialize(_definition, _name, _initial_value = 0, _options = {})
          @initial_value = _initial_value
          super(_definition, _name, _options)
        end

        def execute(_group_item, _item)
          if !_group_item.respond_to?(item_name)
            _group_item.define_attribute(item_name, initial_value, false)
          end

          result = definition.call(_group_item, _item)
          _group_item.send("#{item_name}=", result)
          mask.execute(_group_item) if mask
          nil
        end
      end
    end
  end
end
