module Organizer
  module Source
    class Item
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer
    end
  end
end
