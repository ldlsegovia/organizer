module Organizer
  module CollectionItem
    attr_reader :item_name

    def has_name?(_name)
      !!item_name && item_name.to_sym == _name.to_sym
    end
  end
end
