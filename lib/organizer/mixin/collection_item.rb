module Organizer
  module CollectionItem
    attr_reader :name

    # Check if this collection item has name passed as param
    #
    # @param _name [String]
    # @return [Boolean]
    def has_name?(_name)
      !!self.name && self.name.to_sym == _name.to_sym
    end
  end
end
