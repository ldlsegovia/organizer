class Organizer::FiltersCollection < Array
  include Organizer::Error

  def <<(_item)
    raise_error(:invalid_item) if !_item.is_a?(Organizer::Filter)
    super
  end

  # Returns filters included into _filter_names array
  #
  # param _filter_names [Array] filter names to select
  # @return [Organizer::FiltersCollection]
  def select_filters(_filter_names)
    filters = Organizer::FiltersCollection.new
    return filters if empty_filter_names?(_filter_names)
    self.each { |filter| filters << filter if filter_in_names?(filter, _filter_names) }
    filters
  end

  # Returns all filters except ones included into _filter_names array
  #
  # param _filter_names [Array] filter names to exlcude
  # @return [Organizer::FiltersCollection]
  def reject_filters(_filter_names)
    return self if empty_filter_names?(_filter_names)
    filters = Organizer::FiltersCollection.new
    self.each { |filter| filters << filter unless filter_in_names?(filter, _filter_names) }
    filters
  end

  # Find filter by name
  #
  # param _name [Symbol] filter's name
  # @return [Organizer::Filter]
  def filter_by_name _name
    return unless _name
    self.find { |filter| filter.has_name?(_name) }
  end

  private

  def filter_in_names?(_filter, _filter_names)
    !!_filter.name && _filter_names.map(&:to_sym).include?(_filter.name.to_sym)
  end

  def empty_filter_names?(_filter_names)
    !_filter_names.is_a?(Array) || _filter_names.count <= 0
  end
end
