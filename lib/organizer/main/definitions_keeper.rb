class Organizer::DefinitionsKeeper
  include Organizer::Error

  attr_accessor :collection_options
  attr_reader :collection_proc, :groups, :filters, :default_filters, :operations, :group_operations

  def initialize
    @groups = Organizer::Group::Collection.new
    @filters = Organizer::Filter::Collection.new
    @default_filters = Organizer::Filter::Collection.new
    @operations = Organizer::Operation::Collection.new
    @group_operations = Organizer::Operation::Collection.new
  end

  def add_collection(&block)
    @collection_proc = block
    nil
  end

  def collection
    raise_error(:undefined_collection_method) unless collection_proc
    Organizer::Source::Collection.new.fill(collection_proc.call(collection_options))
  end

  def add_default_filter(_name = nil, &block)
    default_filters.add_filter(_name, &block)
  end

  def add_filter(_name, &block)
    filters.add_filter(_name, &block)
  end

  def add_simple_operation(_name, &block)
    operations.add_simple_operation(_name, &block)
  end

  def add_memo_operation(_name, _initial_value = 0, &block)
    group_operations.add_memo_operation(_name, _initial_value, &block)
  end

  def add_group(_name, _group_by_attr = nil, _parent_name = nil)
    groups.add_group(_name, _group_by_attr, _parent_name)
  end
end
