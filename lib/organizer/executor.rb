module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      @definitions = _definitions
      @chainer = _chainer
      @executors = []

      load_source_operations
      load_source_default_filters
      load_source_filters
      load_source_sort_items

      load_groups
      load_group_operations
      load_group_filters
      load_group_sort_items

      execute(@executors.shift, _definitions.collection, @executors)
    end

    def self.load_source_operations
      load_executor do |source|
        Organizer::Source::Operation::Executor.execute(@definitions.source_operations, source)
      end
    end

    def self.load_source_default_filters
      filters = Organizer::Source::Filter::Selector.select_default(
        @definitions.source_default_filters, @chainer.skip_default_filter_methods)

      load_executor do |source|
        Organizer::Source::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_source_filters
      filters = Organizer::Source::Filter::Selector.select(
        @definitions.filters, @chainer.filter_methods(:hash))

      load_executor do |source|
        Organizer::Source::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_source_sort_items
      sort_items = Organizer::Source::Sort::Builder.build(@chainer.sort_methods(:hash))

      load_executor do |source|
        Organizer::Source::Sort::Applier.apply(sort_items, source)
      end
    end

    def self.load_groups
      @selected_group_definitions = Organizer::Group::Selector.select(
        @definitions.groups, @chainer.group)

      load_executor do |source|
        groups = @selected_group_definitions.groups_from_definitions if @selected_group_definitions
        Organizer::Group::Builder.build(source, groups)
      end
    end

    def self.load_group_operations
      Organizer::Group::Operation::Loader.load(@definitions, @selected_group_definitions)
      load_group_parent_item_operations
      load_group_item_operations
    end

    def self.load_group_parent_item_operations
      load_executor do |source|
        Organizer::Group::Operation::ParentItemsExecutor.execute(
          @selected_group_definitions, @definitions.collection, source)
      end
    end

    def self.load_group_item_operations
      load_executor do |source|
        Organizer::Group::Operation::ItemsExecutor.execute(
          @selected_group_definitions, source)
      end
    end

    def self.load_group_filters
      grouped_filters = Organizer::Group::Filter::Selector.select(
        @definitions.filters, @chainer.filter_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Group::Filter::Applier.apply(grouped_filters, source)
      end
    end

    def self.load_group_sort_items
      Organizer::Group::Sort::Builder.build(
        @chainer.sort_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Group::Sort::Applier.apply(@selected_group_definitions, source)
      end
    end

    def self.load_executor
      @executors << Proc.new do |source|
        yield(source)
      end
    end

    def self.execute(_proc, _source, _next_procs)
      return _source unless _proc
      result = _proc.call(_source)
      next_proc = _next_procs.shift
      return result unless next_proc
      execute(next_proc, result, _next_procs)
    end
  end
end
