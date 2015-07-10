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

  class DSLException < ::Exception
    ERRORS = {
      invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string",
      forbidden_nesting: "Forbidden nesting definition detected"
    }
  end

  class Exception < ::Exception
    ERRORS = {
      undefined_collection_method: "Undefined collection method. You need to add collection(){} into Organizer.define block"
    }
  end

  module Source
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid item for collection. Must be Organizer::Source::Item instance",
        invalid_collection_structure: "Invalid collection structure. Must be Array",
        invalid_collection_item_structure: "Invalid collection item structure. Must be a Hash"
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        must_be_a_hash: "_hash parameter must be a Hash",
        invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
        attributes_handler_not_included: "The class must contain Organizer::AttributesHandler mixin"
      }
    end
  end

  module Filter
    class ItemException < ::Exception
      ERRORS = {
        definition_must_be_a_proc: "Filter definition must be a Proc",
        apply_on_organizer_items_only: "Filters can be applied on Organizer::Source::Items only",
        definition_must_return_boolean: "Invalid filter definition result. The definition bock call must return a boolean value"
      }
    end

    class ManagerException < ::Exception
      ERRORS = {
        generate_over_organizer_items_only: "Can generate usual filters only based on Organizer::Source::Items only",
      }
    end

    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid filter collection item. Must be Organizer:Filter only"
      }
    end
  end

  module Operation
    class ItemException < ::Exception
      ERRORS = {
        blank_name: "Operation name param is mandatory",
        execute_over_organizer_items_only: "Operations can be executed on Organizer::Source::Items only",
        definition_must_be_a_proc: "Operation definition must be a Proc"
      }
    end

    class GroupItemException < ::Exception
      ERRORS = {
        execute_over_organizer_group_items_only: "Operations can be executed on Organizer::Group::SubItems only",
      }
    end

    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid operations collection item. Must be Organizer:Operation only"
      }
    end

    class ManagerException < ::Exception
      ERRORS = {}
    end
  end

  module Group
    class CollectionException < ::Exception
      ERRORS = {
        invalid_item: "Invalid group collection item. Must be Organizer:Group only"
      }
    end

    class ItemException < ::Exception
      ERRORS = {
        invalid_item: "Invalid group item. Must be Organizer::Group::SubItem only",
        group_by_attr_not_present_in_collection: "group_by_attr is not present in collection Organizer::Source::Items"
      }
    end

    class SubItemException < ::Exception
      ERRORS = {
        must_be_a_hash: "_hash parameter must be a Hash",
        invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
        attributes_handler_not_included: "The class must contain Organizer::AttributesHandler mixin"
      }
    end
  end
end
