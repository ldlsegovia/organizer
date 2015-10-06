class Organizer::Executor
  include Organizer::Error

  def initialize(_organizer)
    @organizer = _organizer
  end

  def run
    executors = build_executors
    execute(executors.shift, @organizer.collection, executors)
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
    skip_method = chained_methods.find { |method| method.is?(:skip_default_filters) }
    filter_by = []

    if skip_method
      filter_by = skip_method.args? ? skip_method.args : :all
    end

    _executors << Proc.new do |source|
      Organizer::Filter::Applier.apply_default(@organizer.default_filters, source, filter_by)
    end
  end

  def load_filters_executor(_executors)
    args = {}

    chained_methods.each do |method|
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
      Organizer::Filter::Applier.apply(get_filters, source, args)
    end unless args.keys.empty?
  end

  def get_filters
    generated_filters = Organizer::Filter::Generator.generate(@organizer.collection.first)
    filters = Organizer::Filter::Collection.new
    generated_filters.each { |gf| filters << gf }
    @organizer.filters.each { |f| filters << f }
    filters
  end

  def load_operations_executor(_executors)
    _executors << Proc.new do |source|
      Organizer::Operation::Executor.execute(@organizer.operations, source)
    end
  end

  def load_group_operations_executor(_executors)
    _executors << Proc.new do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Operation::Executor.execute(
          @organizer.group_operations, @organizer.collection, source)
      else
        source
      end
    end
  end

  def load_groups_executor(_executors)
    args = []

    chained_methods.each do |method|
      if [:group_by].include?(method.name)
        method.args.each do |arg|
          args << arg if arg.is_a?(Symbol) || arg.is_a?(String)
        end
      end
    end

    args.uniq!

    _executors << Proc.new do |source|
      Organizer::Group::Builder.build(source, @organizer.groups, args)
    end unless args.empty?
  end

  def execute(_proc, _source, _next_procs)
    return _source unless _proc
    result = _proc.call(_source)
    next_proc = _next_procs.shift
    return result unless next_proc
    execute(next_proc, result, _next_procs)
  end

  def chained_methods
    @organizer.chainer.chained_methods
  end
end
