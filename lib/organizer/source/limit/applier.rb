module Organizer
  module Source
    module Limit
      module Applier
        include Organizer::Error

        def self.apply(_limit_item, _collection)
          return _collection if _limit_item.blank? || _collection.blank?
          _collection = _collection[0, _limit_item.value]
        end
      end
    end
  end
end
