class Organizer::FiltersManager
  include Organizer::Error

  # Creates a new {Organizer::Filter} and adds to default filters collection.
  #   Default filters intend to be applied by default. You won't need to call this filters explicitly.
  #
  # @param _name [optional, Symbol] filter's name. Not mandatory for default filters.
  # @yield code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item] you can use item's attributes in your conditions.
  # @yieldreturn [Boolean]
  # @return [Organizer::Filter]
  def add_default_filter(_name = nil, &block)
    default_filters << Organizer::Filter.new(block, _name)
    default_filters.last
  end

  # Creates a new {Organizer::Filter} and adds to normal filters collection.
  #   This kind of filters need to be called explicitly using filter's name.
  #
  # @param _name [Symbol] filter's name.
  # @yield code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item] you can use item's attributes in your conditions.
  # @yieldreturn [Boolean]
  # @return [Organizer::Filter]
  def add_normal_filter(_name, &block)
    normal_filters << Organizer::Filter.new(block, _name)
    normal_filters.last
  end

  # Creates a new {Organizer::Filter} (with true accept_value) and adds to filters with values collection.
  #   This kind of filters need to be called explicitly using filter's name and expect a value param.
  #
  # @param _name [Symbol] filter's name.
  # @yield  code that must return a Boolean value.
  # @yieldparam organizer_item [Organizer::Item] you can use item's attributes in your conditions.
  # @yieldparam value [Object] you can use this value in your conditions. Can be anything.
  # @yieldreturn [Boolean]
  # @return [Organizer::Filter]
  def add_filter_with_value(_name, &block)
    filters_with_values << Organizer::Filter.new(block, _name, true)
    filters_with_values.last
  end

  # Applies default and normal filters to give collection.
  #   To apply a normal filter, need to pass filter names inside array in _options like this:
  #   { enabled_filters: [my_filter] }.
  #   To skip a default filter, need to pass default filter names inside array in _options like this:
  #   { skip_default_filters: [my_filter] }.
  #   If you want to skip all default filters: { skip_default_filters: :all }.
  #   To apply filters with values, need to pass filter_key filter_value pairs in _options like this:
  #   { my_filter: 4, other_filter: 6 }.
  #
  # @param _options [Hash]
  # @param _collection [Organizer::Collection] the whole collection
  # @return [Organizer::Collection] a filtered collection
  def apply(_collection, _options = {})
    filtered_collection = apply_default_fitlers(_collection, _options)
    filtered_collection = apply_normal_filters(filtered_collection, _options)
    apply_filters_with_values(filtered_collection, _options)
  end

  private

  def default_filters
    @default_filters ||= Organizer::FiltersCollection.new
  end

  def normal_filters
    @normal_filters ||= Organizer::FiltersCollection.new
  end

  def filters_with_values
    @filters_with_values ||= Organizer::FiltersCollection.new
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

  def apply_filters_with_values(_collection, _options = {})
    filter_pairs = _options.fetch(:filters, {})
    selected_filters = select_filters(filters_with_values, filter_pairs.keys)
    apply_filters(selected_filters, _collection, filter_pairs)
  end

  def select_filters(_filters, _filter_names)
    _filters.select { |filter| _filter_names.include?(filter.name) }
  end

  def reject_filters(_filters, _filter_names)
    _filters.reject { |filter| _filter_names.include?(filter.name) }
  end

  def apply_filters(_filters, _collection, _filters_values = nil)
    return _collection if _filters.count <= 0
    _collection.reject do |item|
      reject_item = false
      _filters.each do |filter|
        value = get_filter_value(filter, _filters_values)
        if !filter.apply(item, value)
          reject_item = true
          break
        end
      end
      reject_item
    end
  end

  def get_filter_value(_filter, _filters_values)
    return if !_filter.accept_value || !_filters_values
    _filters_values[_filter.name]
  end
end
