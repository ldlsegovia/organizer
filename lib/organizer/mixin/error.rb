module Organizer
  module Error
    def self.included(_base)
      _base.extend(ClassMethods)
    end

    def raise_error(_key)
      self.class.raise_error(_key)
    end

    module ClassMethods
      def raise_error(_msg)
        error_class = eval("#{self}Exception") rescue nil
        error_class = Organizer::Exception unless error_class
        error_msg = error_class::ERRORS[_msg] || _msg
        raise error_class.new(error_msg)
      end
    end
  end

  class Exception < ::Exception
    ERRORS = {
      undefined_collection_method: "Undefined collection method. You need to add collection(){} into Organizer.define block"
    }
  end

  class DSLException < ::Exception
    ERRORS = {
      invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string",
      forbidden_nesting: "Forbidden nesting definition detected"
    }
  end

  class ChainerException < ::Exception
    ERRORS = {
      invalid_chaining: "Invalid chaining",
    }
  end

  module Source
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid item for collection. Must be Organizer::Source::Item instance",
        repeated_item: "Repeated item. An Item with same name was added previously",
        invalid_collection_structure: "Invalid collection structure. Must be Array",
        invalid_collection_item_structure: "Invalid collection item structure. Must be a Hash"
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        must_be_a_hash: "_hash parameter must be a Hash",
        invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
        attr_already_defined: "Attribute already defined",
        attributes_handler_not_included: "The class must contain Organizer::AttributesHandler mixin"
      }
    end

    module Filter
      class SelectorException < ::Exception
        ERRORS = {
          unknown_filter: "Cant apply unknown filters"
        }
      end
    end

    module Operation
      class ExecutorException < ::Exception
        ERRORS = {}
      end
    end
  end

  module Filter
    class ItemException < ::Exception
      ERRORS = {
        definition_must_be_a_proc: "Filter definition must be a Proc",
        apply_on_collection_items_only: "Filters can be applied on Organizer::CollectionItem only",
        definition_must_return_boolean: "Invalid filter definition result. The definition bock call must return a boolean value"
      }
    end

    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid filter collection item. Must be Organizer:Filter only",
        repeated_item: "Repeated item. An Item with same name was added previously"
      }
    end
  end

  module Operation
    class ItemException < ::Exception
      ERRORS = {
        not_implemented: "Must override on child classes",
        blank_name: "Operation name param is mandatory",
        definition_must_be_a_proc: "Operation definition must be a Proc"
      }
    end

    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid operations collection item.",
        repeated_item: "Repeated item. An Item with same name was added previously"
      }
    end

    class MaskBuilderException < ::Exception
      ERRORS = {
        invalid_mask: "Invalid mask given"
      }
    end
  end

  module Sort
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid item for collection. Must be Organizer::Sort::Item instance",
        repeated_item: "Repeated item. An Item with same name was added previously",
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        blank_name: "name param is mandatory",
      }
    end
  end

  module Limit
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid item for collection. Must be Organizer::Limit::Item instance",
        repeated_item: "Repeated item. An Item with same name was added previously",
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        blank_name: "name param is mandatory",
        not_integer_value: "It is not a positive integer"
      }
    end
  end

  module Group
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid group collection item. Must be Organizer::Group::Item only",
        repeated_item: "Repeated item. An Item with same name was added previously"
      }
    end

    class DefinitionsCollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid group collection item. Must be Organizer::Group::Definition only",
        repeated_item: "Repeated item. An Item with same name was added previously",
        definition_not_found: "Group definition not found"
      }
    end

    class DefinitionException < ::Exception
      ERRORS = {
        must_be_a_hash: "_hash parameter must be a Hash",
        invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
        attr_already_defined: "Attribute already defined",
        attributes_handler_not_included: "The class must contain Organizer::AttributesHandler mixin"
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        invalid_item: "Invalid group item. Must be Organizer::Group::Item only",
        repeated_item: "Repeated item. An Item with same name was added previously",
        must_be_a_hash: "_hash parameter must be a Hash",
        invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
        attr_already_defined: "Attribute already defined",
        attributes_handler_not_included: "The class must contain Organizer::AttributesHandler mixin"
      }
    end

    class SelectorException < ::Exception
      ERRORS = {
        unknown_group: "Cant group by unknown group"
      }
    end

    module Filter
      class SelectorException < ::Exception
        ERRORS = {
          unknown_group: "Cant apply filters to unknown group",
          unknown_filter: "Cant apply unknown filters"
        }
      end
    end

    module Sort
      class BuilderException < ::Exception
        ERRORS = {
          unknown_group: "Cant sort unknown groups"
        }
      end
    end
  end
end
