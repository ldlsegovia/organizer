class Organizer::ExecutorArgs
  include Organizer::Error

  def initialize(_collection_methods, _group_methods)
    @collection_methods = _collection_methods
    @group_methods = _group_methods
  end

  def default_filters_to_skip
    skip_methods = @collection_methods.select(&:skip_default_filters?)
    return if skip_methods.empty?
    skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
    args = skip_methods.map(&:args).flatten
    return :all if skip_all || args.blank?
    args
  end

  def filters(_methods = nil)
    args = {}
    _methods ||= @collection_methods

    _methods.each do |method|
      next unless method.filter_by?
      method.args.each do |arg|
        if hash?(arg)
          args.merge!(arg)
        elsif string?(arg)
          args[arg] = nil
        end
      end
    end

    return if args.keys.empty?
    args
  end

  def sort_items(_methods = nil)
    args = Organizer::Sort::Collection.new
    _methods ||= @collection_methods

    _methods.each do |method|
      next unless method.sort_by?
      method.args.each do |arg|
        if hash?(arg)
          arg.each { |attr_name, orientation| add_sort_item(args, attr_name, orientation) }
        elsif string?(arg)
          add_sort_item(args, arg)
        end
      end
    end

    return if args.empty?
    args
  end

  def groups_sort_items
    args = {}
    group_sort_items = []

    @group_methods.reverse_each do |method|
      if method.sort_by?
        group_sort_items << method
      elsif method.group_by? && !group_sort_items.empty?
        group_sort_items_args = sort_items(group_sort_items)
        args[method.args.first] = group_sort_items_args if group_sort_items_args
        group_sort_items = []
      end
    end

    return if args.keys.empty?
    args
  end

  def groups
    args = []

    @group_methods.each do |method|
      next unless method.group_by?
      args += method.args
    end

    return if args.empty?
    args.uniq
  end

  def groups_filters
    args = {}
    group_filters = []

    @group_methods.reverse_each do |method|
      if method.filter_by?
        group_filters << method
      elsif method.group_by? && !group_filters.empty?
        group_filters_args = filters(group_filters)
        args[method.args.first] = group_filters_args if group_filters_args
        group_filters = []
      end
    end

    return if args.keys.empty?
    args
  end

  private

  def add_sort_item(_args, _attr_name, _orientation = nil)
    descending = true if _orientation.to_s == "desc"
    _args.add_item(_attr_name.to_sym, descending)
  end

  def string?(_arg)
    _arg.is_a?(Symbol) || _arg.is_a?(String)
  end

  def hash?(_arg)
    _arg.is_a?(Hash)
  end
end
