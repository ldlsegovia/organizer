class Organizer::Executor
  include Organizer::Error

  def initialize(_definitons_keeper, _chained_methods)
    @definitions = _definitons_keeper
    @chained_methods = _chained_methods
  end

  def run
    executors = build_executors
    execute(executors.shift, @definitions.collection, executors)
  end

  private

  def build_executors
    executors = []
    load_operations_executor(executors)
    load_default_filters_executor(executors)
    load_filters_executor(executors)
    load_groups_executor(executors)
    load_group_operations_executor(executors)
    executors
  end

  def load_default_filters_executor(_executors)
    skip_method = @chained_methods.find { |method| method.is?(:skip_default_filters) }
    filter_by = []

    if skip_method
      args = skip_method.args
      filter_by = args.include?(:all) || args.empty? ? :all : args
    end

    _executors << Proc.new do |source|
      Organizer::Filter::Applier.apply(@definitions.default_filters, source, skipped_filters: filter_by)
    end
  end

  def load_filters_executor(_executors)
    args = {}

    @chained_methods.each do |method|
      next unless [:filter_by].include?(method.name)
      method.args.each do |arg|
        if arg.is_a?(Hash)
          args.merge!(arg)
        elsif arg.is_a?(Symbol) || arg.is_a?(String)
          args[arg] = nil
        end
      end
    end

    _executors << Proc.new do |source|
      Organizer::Filter::Applier.apply(get_filters, source, selected_filters: args)
    end unless args.keys.empty?
  end

  def get_filters
    generated_filters = Organizer::Filter::Generator.generate(@definitions.collection.first)
    filters = Organizer::Filter::Collection.new
    generated_filters.each { |gf| filters << gf }
    @definitions.filters.each { |f| filters << f }
    filters
  end

  def load_operations_executor(_executors)
    _executors << Proc.new do |source|
      Organizer::Operation::Executor.execute(@definitions.operations, source)
    end
  end

  def load_group_operations_executor(_executors)
    _executors << Proc.new do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Operation::Executor.execute(
          @definitions.group_operations, @definitions.collection, source)
      else
        source
      end
    end
  end

  def load_groups_executor(_executors)
    args = []

    @chained_methods.each do |method|
      if [:group_by].include?(method.name)
        method.args.each do |arg|
          args << arg if arg.is_a?(Symbol) || arg.is_a?(String)
        end
      end
    end

    args.uniq!

    _executors << Proc.new do |source|
      Organizer::Group::Builder.build(source, @definitions.groups, args)
    end unless args.empty?
  end

  def execute(_proc, _source, _next_procs)
    return _source unless _proc
    result = _proc.call(_source)
    next_proc = _next_procs.shift
    return result unless next_proc
    execute(next_proc, result, _next_procs)
  end
end
