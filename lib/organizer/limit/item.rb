module Organizer
  module Limit
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :value

      def initialize(_name, _value)
        raise_error(:blank_name) unless _name
        raise_error(:not_integer_value) unless /\A\d+\z/.match(_value.to_s)
        @value = _value
        @item_name = _name
      end
    end
  end
end
