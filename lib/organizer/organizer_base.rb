class OrganizerBase
  include Organizer::Error

  def self.collection(&block)
    define_method :collection do
      result = block.call

      raise_error(:invalid_collection_structure) unless result.is_a?(Array)

      if result.count > 0 && !result.first.is_a?(Hash)
        raise_error(:invalid_collection_item_structure)
      end

      result
    end

    private :collection
  end

  def method_missing(_m, *args, &block)
    raise_error(:undefined_collection_method) if _m == :collection
  end

end
