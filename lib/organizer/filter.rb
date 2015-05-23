class Organizer::Filter
  include Organizer::Error

  attr_reader :definition, :name

  # @param _definition [Proc] contains logic to decide if filter must be applied or not
  # @param _name [Symbol] symbol to identify this particular filter
  def initialize(_definition, _name = nil)
    if !_definition.is_a?(Proc)
      raise_error(:filter_definition_must_be_a_proc)
    end
    @definition = _definition
    @name = _name
  end

  # Evaluates _item param against definition proc to know if item
  # must be filtered or not.
  #
  # @param _item [Organizer::Item]
  # @return [Boolean]
  #
  # @raise [Organizer::Exception] :filter_applied_on_organizer_items_only and
  #   :filter_definition_must_return_boolean
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
    if !_item.is_a?(Organizer::Item)
      raise_error(:filter_applied_on_organizer_items_only)
    end

    result = definition.call(_item)

    if !!result != result
      raise_error(:filter_definition_must_return_boolean)
    end

    result
  end
end
