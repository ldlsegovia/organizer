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
    generate_usual_filters(_collection.first)
    filtered_collection = apply_default_fitlers(_collection, _options)
    filtered_collection = apply_normal_filters(filtered_collection, _options)
    apply_filters_with_values(filtered_collection, _options)
  end

  # Generates common filters based on _item attributes. If you have an {Organizer::Item} with a single
  #   attribute named "my_attr". After run this method you will have these filters:
  #   * my_attr_eq: match attribute equals to...
  #   * my_attr_not_eq: match attribute different to...
  #   * my_attr_gt: match attribute greater than...
  #   * my_attr_lt: match attribute lower than...
  #   * my_attr_goet: match attribute greater or equal than...
  #   * my_attr_loet: match attribute lower or equal than...
  #   * my_attr_contains: match attribute containing string...
  #   * my_attr_starts: match attribute starting with string...
  #   * my_attr_ends: match attribute ending with string...
  def generate_usual_filters(_item)
    return unless _item
    raise_error(:generate_over_organizer_items_only) unless _item.is_a? Organizer::Item
    _item.attribute_names.each do |attribute|
      generate_attr_filter(attribute, :eq) { |item, value| item.send(attribute) == value }
      generate_attr_filter(attribute, :not_eq) { |item, value| item.send(attribute) != value }
      generate_attr_filter(attribute, :gt) { |item, value| item.send(attribute) > value }
      generate_attr_filter(attribute, :goet) { |item, value| item.send(attribute) >= value }
      generate_attr_filter(attribute, :lt) { |item, value| item.send(attribute) < value }
      generate_attr_filter(attribute, :loet) { |item, value| item.send(attribute) <= value }
      generate_attr_filter(attribute, :contains) { |item, value| !!item.send(attribute).to_s[value.to_s] }
      generate_attr_filter(attribute, :starts) { |item, value| item.send(attribute).to_s.start_with?(value.to_s) }
      generate_attr_filter(attribute, :ends) { |item, value| item.send(attribute).to_s.end_with?(value.to_s) }
    end
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

  def all_filters
    filters = Organizer::FiltersCollection.new
    default_filters.each { |f| filters << f }
    normal_filters.each { |f| filters << f }
    filters_with_values.each { |f| filters << f }
  end

  def generate_attr_filter(_attr, _sufix, &proc)
    add_filter_with_value("#{_attr}_#{_sufix}", &proc)
  end

  def apply_default_fitlers(_collection, _options = {})
    filter_by = _options.fetch(:skip_default_filters, [])
    selected_filters = (filter_by == :all) ? nil : default_filters.reject_filters(filter_by)
    apply_filters(selected_filters, _collection)
  end

  def apply_normal_filters(_collection, _options = {})
    filter_names = _options.fetch(:enabled_filters, [])
    selected_filters = normal_filters.select_filters(filter_names)
    apply_filters(selected_filters, _collection)
  end

  def apply_filters_with_values(_collection, _options = {})
    filter_pairs = _options.fetch(:filters, {})
    selected_filters = filters_with_values.select_filters(filter_pairs.keys)
    apply_filters(selected_filters, _collection, filter_pairs)
  end

  def apply_filters(_filters, _collection, _filters_values = nil)
    return _collection unless _filters
    filtered_collection = Organizer::Collection.new
    _collection.each do |item|
      add_item = true
      _filters.each do |filter|
        value = get_filter_value(filter, _filters_values)
        if !filter.apply(item, value)
          add_item = false
          break
        end
      end
      filtered_collection << item if add_item
    end
    filtered_collection
  end

  def get_filter_value(_filter, _filters_values)
    return if !_filter.accept_value || !_filters_values || !_filter.name
    _filters_values[_filter.name] || _filters_values[_filter.name.to_sym]
  end
end
