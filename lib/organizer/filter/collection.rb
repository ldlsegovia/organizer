module Organizer
  module Filter
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      collectable_classes Organizer::Filter::Item
    end
  end
end
