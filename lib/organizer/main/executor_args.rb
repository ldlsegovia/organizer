class Organizer::ExecutorArgs
  include Organizer::Error

  def initialize(_chained_methods)
    @collection_methods = []
    @group_methods = []
    collection_method = true

    _chained_methods.each do |method|
      collection_method = false if method.group_by?
      !!collection_method ? @collection_methods << method : @group_methods << method
    end
  end

  def default_filters_to_skip
    skip_methods = @collection_methods.select(&:skip_default_filters?)
    return if skip_methods.empty?
    skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
    args = skip_methods.map(&:args).flatten
    return :all if skip_all || args.blank?
    args
  end

  def filters
    args = {}

    @collection_methods.each do |method|
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
end
