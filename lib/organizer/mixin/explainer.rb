module Organizer
  module Explainer
    NEW_LINE = "\n"
    SPACE = "\s"
    TAB = "\s\s"
    DIVIDER = "\s|\s"
    DEFAULT_COLLECTION_LIMIT = 10

    def explain(_colorize = true, _collection_limit = DEFAULT_COLLECTION_LIMIT)
      puts build_output(_colorize, _collection_limit)
    end

    def inspect
      build_output(true, DEFAULT_COLLECTION_LIMIT)
    end

    private

    def build_output(_colorize, _collection_limit)
      result = explain_item(0, "", _collection_limit)
      result = result.uncolorize.gsub("\s\n", "\n") unless _colorize
      result
    end

    def explain_item(_indent = 0, _output = "", _collection_limit = 10)
      load_class_output(_indent, _output)
      load_items_output(_indent, _output, _collection_limit)
      _output
    end

    def load_items_output(_indent = 0, _output = "", _collection_limit = 10)
      return unless self.class.include?(Organizer::Collection)
      _indent += 1
      return if load_empty_items_output(_indent, _output)

      each_with_index do |item, idx|
        if _collection_limit == idx
          diff = size - _collection_limit
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

      if self.is_a?(Organizer::Group::Item)
        parts << group_name.to_s.magenta
        parts << group_by_attr.to_s.magenta if group_name.to_s != group_by_attr.to_s
        parts << item_name.to_s.magenta if group_name.to_s != item_name.to_s

      elsif self.class.include?(Organizer::CollectionItem) && !item_name.blank?
        parts << item_name.to_s.magenta
      end

      if self.class.include?(Organizer::AttributesHandler)
        attrs = get_formatted_attributes
        parts << attrs unless attrs.empty?
      end

      _output << indented_value(parts.join(DIVIDER), _indent)
    end

    def get_formatted_attributes
      output = ""
      attribute_names.each_with_index do |attr_name, idx|
        value = send(attr_name)

        if value.is_a?(String)
          value = "\"#{value}\""
        elsif value.nil?
          value = "nil"
        end

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
