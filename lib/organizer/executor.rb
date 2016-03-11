module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      @definitions = _definitions
      @chainer = _chainer
      @executors = []

      source = load_source_operations(_definitions.collection)
      source = load_source_default_filters(source)
      source = load_source_filters(source)
      source = load_source_sort_items(source)
      source = load_source_limit_items(source)

      groups = load_groups(source)
      load_group_operations(groups, source)
      load_group_filters(groups)
      load_group_sort_items(groups)
      load_group_limit_items(groups)
    end

    def self.load_source_operations(_source)
      Organizer::Source::Operation::Executor.execute(@definitions.source_operations, _source)
    end

    def self.load_source_default_filters(_source)
      filters = Organizer::Source::Filter::Selector.select_default(
        @definitions.source_default_filters, @chainer.skip_default_filter_methods)
      Organizer::Source::Filter::Applier.apply(filters, _source)
    end

    def self.load_source_filters(_source)
      filters = Organizer::Source::Filter::Selector.select(
        @definitions.filters, @chainer.filter_methods(:hash))
      Organizer::Source::Filter::Applier.apply(filters, _source)
    end

    def self.load_source_sort_items(_source)
      sort_items = Organizer::Source::Sort::Builder.build(@chainer.sort_methods(:hash))
      Organizer::Source::Sort::Applier.apply(sort_items, _source)
    end

    def self.load_source_limit_items(_source)
      limit_item = Organizer::Source::Limit::Builder.build(@chainer.limit_methods.first)
      Organizer::Source::Limit::Applier.apply(limit_item, _source)
    end

    def self.load_groups(_source)
      @selected_group_definitions = Organizer::Group::Selector.select(
        @definitions.groups, @chainer.group)
      groups = @selected_group_definitions.groups_from_definitions if @selected_group_definitions
      Organizer::Group::Builder.build(_source, groups)
    end

    def self.load_group_operations(_groups, _source)
      Organizer::Group::Operation::Loader.load(@definitions, @selected_group_definitions)
      load_group_parent_item_operations(_groups, _source)
      load_group_item_operations(_groups)
      load_group_child_item_operations(_groups)
    end

    def self.load_group_parent_item_operations(_groups, _source)
      Organizer::Group::Operation::ParentItemsExecutor.execute(
        @selected_group_definitions, _source, _groups)
    end

    def self.load_group_item_operations(_groups)
      Organizer::Group::Operation::ItemsExecutor.execute(
        @selected_group_definitions, _groups)
    end

    def self.load_group_child_item_operations(_groups)
      Organizer::Group::Operation::ChildItemsExecutor.execute(
        @selected_group_definitions, _groups)
    end

    def self.load_group_filters(_groups)
      grouped_filters = Organizer::Group::Filter::Selector.select(
        @definitions.filters, @chainer.filter_group_methods(:hash), @selected_group_definitions)
      Organizer::Group::Filter::Applier.apply(grouped_filters, _groups)
    end

    def self.load_group_sort_items(_groups)
      Organizer::Group::Sort::Builder.build(
        @chainer.sort_group_methods(:hash), @selected_group_definitions)
      Organizer::Group::Sort::Applier.apply(@selected_group_definitions, _groups)
    end

    def self.load_group_limit_items(_groups)
      Organizer::Group::Limit::Builder.build(
        @chainer.limit_group_methods, @selected_group_definitions)
      Organizer::Group::Limit::Applier.apply(@selected_group_definitions, _groups)
    end
  end
end
