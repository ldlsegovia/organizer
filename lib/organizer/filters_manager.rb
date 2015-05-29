class Organizer::FiltersManager
  include Organizer::Error

  # Creates a new {Organizer::Filter} and adds to default filters collection.
  #
  # @param _name [Symbol] filter's name. Not mandatory for default filters.
  # @return [Organizer::Filter]
  #
  # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item]
  # @yieldreturn [Boolean]
  def add_default_filter(_name = nil, &block)
    default_filters << Organizer::Filter.new(block, _name)
    default_filters.last
  end

  # Creates a new {Organizer::Filter} and adds to normal filters collection.
  #
  # @param _name [Symbol] filter's name.
  # @return [Organizer::Filter]
  #
  # @yield you can use the {Organizer::Item} instance param to evaluate a condition and return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item]
  # @yieldreturn [Boolean]
  def add_normal_filter(_name, &block)
    normal_filters << Organizer::Filter.new(block, _name)
    normal_filters.last
  end

  # Applies default and normal filters to give collection.
  # To apply a normal filter, need to pass filter names inside array in _options like this: { enabled_filters: [my_filter] }.
  # To skip a default filter, need to pass default filter names inside array in _options like this: { skip_default_filters: [my_filter] }.
  # If you want to skip all default filters: { skip_default_filters: :all }.
  #
  # @param _options [Hash]
  # @param _collection [Organizer::Collection] the whole collection
  # @return [Organizer::Collection] a filtered collection
  def apply(_collection, _options = {})
    result = apply_default_fitlers(_collection, _options)
    apply_normal_filters(result, _options)
  end

  private

  def default_filters
    @default_filters ||= Organizer::FiltersCollection.new
  end

  def normal_filters
    @normal_filters ||= Organizer::FiltersCollection.new
  end

  def apply_default_fitlers(_collection, _options = {})
    filter_by = _options.fetch(:skip_default_filters, [])
    selected_filters = (filter_by == :all) ? [] : reject_filters(default_filters, filter_by)
    apply_filters(selected_filters, _collection)
  end

  def apply_normal_filters(_collection, _options = {})
    filter_names = _options.fetch(:enabled_filters, [])
    selected_filters = select_filters(normal_filters, filter_names)
    apply_filters(selected_filters, _collection)
  end

  def select_filters(_filters, _filter_names)
    _filters.select { |filter| _filter_names.include?(filter.name) }
  end

  def reject_filters(_filters, _filter_names)
    _filters.reject { |filter| _filter_names.include?(filter.name) }
  end

  def apply_filters(_filters, _collection)
    return _collection if _filters.count <= 0
    _collection.reject do |item|
      reject_item = false
      _filters.each do |filter|
        if !filter.apply(item)
          reject_item = true
          break
        end
      end
      reject_item
    end
  end
end