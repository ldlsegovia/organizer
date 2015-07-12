module Organizer
  module Source
    class Item
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
    end
  end
end
