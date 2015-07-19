module Organizer
  module Explainer
    NEW_LINE = "\n"
    SPACE = "\s"
    TAB = "\s\s"
    DIVIDER = "\s|\s"

    # It returns a nice output for Organizer entities
    #
    # @param _colorize [Boolean]
    # @param _collection_limit [Integer]
    def explain(_colorize = true, _collection_limit = 10)
      result = explain_item(0, "", _collection_limit)
      result = result.uncolorize.gsub("\s\n","\n") unless _colorize
      puts result
    end

    private

    def explain_item(_indent = 0, _output = "", _collection_limit = 10)
      load_class_output(_indent, _output)
      load_items_output(_indent, _output, _collection_limit)
      _output
    end

    def load_items_output(_indent = 0, _output = "", _collection_limit = 10)
      return unless self.class.include?(Organizer::Collection)
      _indent += 1
      return if load_empty_items_output(_indent, _output)

      self.each_with_index do |item, idx|
        if _collection_limit == idx
          diff = self.size - _collection_limit
          text = "and #{diff} more collection items...".colorize(get_class_color(item.class))
          _output << indented_value(text, _indent)
          break
        end

        item.send(:explain_item, _indent, _output)
      end
    end

    def load_empty_items_output(_indent = 0, _output = "")
      if self.empty?
        text = "Empty collection..."
        color = :white
        self.class.item_classes.each { |klass| color = get_class_color(klass) }
        _output << indented_value(text.colorize(color), _indent)
      end
    end

    def load_class_output(_indent = 0, _output = "")
      formatted_class_name = self.class.name.gsub("Organizer::", "").colorize(get_class_color)
      parts = [formatted_class_name]

      if self.class.include?(Organizer::CollectionItem) && !self.name.blank?
        parts << self.name.to_s.magenta
      end

      if self.class.include?(Organizer::AttributesHandler)
        attrs = get_formatted_attributes
        parts << attrs unless attrs.empty?
      end

      _output << indented_value(parts.join(DIVIDER), _indent)
    end

    def get_formatted_attributes
      output = ""
      self.attribute_names.each_with_index do |attr_name, idx|
        value = self.send(attr_name)
        value = "\"#{value}\"" if value.is_a?(String)
        formatted_attr_name = "#{attr_name}=#{value}#{SPACE}"
        output << (idx.odd? ? formatted_attr_name.light_blue : formatted_attr_name.cyan)
      end
      output
    end

    def get_class_color(_class = nil)
      _class = self.class unless _class
      c = _class.include?(Organizer::Collection)
      i = _class.include?(Organizer::CollectionItem)
      return :light_green if c && i
      return :green if c
      :light_yellow
    end

    def indented_value(_value = "", _indent = 0)
      (TAB * _indent) + _value.rstrip + NEW_LINE
    end
  end
end
