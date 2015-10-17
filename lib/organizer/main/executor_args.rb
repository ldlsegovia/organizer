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
        if arg.is_a?(Hash)
          args.merge!(arg)
        elsif arg.is_a?(Symbol) || arg.is_a?(String)
          args[arg] = nil
        end
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
end
