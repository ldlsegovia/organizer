module Organizer
  module Limit
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Limit::Item

      def add(_name, _value)
        self << Organizer::Limit::Item.new(_name, _value)
        last
      end
    end
  end
end
