class Organizer::GroupItem < Array
  include Organizer::Error
  include Organizer::AttributesHandler

  # @param _items [Array] containing Organizer::Item
  def initialize(_items = nil)
    if !_items.blank?
      self.clone_attributes(_items.first)
      super(_items)
    end
  end
end
