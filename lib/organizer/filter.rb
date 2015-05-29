class Organizer::Filter
  include Organizer::Error

  attr_reader :definition, :name, :value

  # @param _definition [Proc] contains logic to decide if filter must be applied or not
  # @param _name [Symbol] symbol to identify this particular filter
  def initialize(_definition, _name = nil, _value = nil)
    raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
    @definition = _definition
    @name = _name
    @value = _value
  end

  # Evaluates _item param against definition proc to know if item
  # must be filtered or not.
  #
  # @param _item [Organizer::Item]
  # @return [Boolean]
  #
  # @raise [Organizer::FilterException] :apply_on_organizer_items_only and
  #   :definition_must_return_boolean
  #
  # @example
  #   hash = { attr1: 400, attr2: 266 }
  #   item = Organizer::Item.new
  #   item.define_attributes(hash)
  #
  #   proc = Proc.new do |organizer_item|
  #     result = organizer_item.attr1 + organizer_item.attr2
  #     result == 666
  #   end
  #
  #   Organizer::Filter.new(proc).apply(item)
  #   #=> true
  def apply(_item)
    raise_error(:apply_on_organizer_items_only) if !_item.is_a?(Organizer::Item)
    result = !!value ? definition.call(_item, value) : definition.call(_item)
    raise_error(:definition_must_return_boolean) if !!result != result
    result
  end
end
