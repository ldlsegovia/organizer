module Organizer
  module Filter
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Filter::Item
    end
  end
end
