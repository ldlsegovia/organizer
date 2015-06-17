class Organizer::Exception < ::Exception
  ERRORS = {
    undefined_collection_method: "Undefined collection method. You need to add collection(){} into Organizer::Template.define block"
  }
end

class Organizer::DSLException < ::Exception
  ERRORS = {
    invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string"
  }
end

class Organizer::CollectionException < ::Exception
  ERRORS = {
    invalid_item: "Invalid item for collection. Must be Organizer::Item instance",
    invalid_collection_structure: "Invalid collection structure. Must be Array",
    invalid_collection_item_structure: "Invalid collection item structure. Must be a Hash"
  }
end

class Organizer::ItemException < ::Exception
  ERRORS = {
    must_be_a_hash: "_hash parameter must be a Hash",
    invalid_attribute_key: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters"
  }
end

class Organizer::FilterException < ::Exception
  ERRORS = {
    definition_must_be_a_proc: "Filter definition must be a Proc",
    apply_on_organizer_items_only: "Filters can be applied on Organizer::Items only",
    definition_must_return_boolean: "Invalid filter definition result. The definition bock call must return a boolean value"
  }
end

class Organizer::FiltersManagerException < ::Exception
  ERRORS = {
    generate_over_organizer_items_only: "Can generate usual filters only based on Organizer::Items only",
  }
end

class Organizer::FiltersCollectionException < ::Exception
  ERRORS = {
    invalid_item: "Invalid filter collection item. Must be Organizer:Filter only"
  }
end

class Organizer::OperationException < ::Exception
  ERRORS = {
    blank_name: "Operation name param is mandatory",
    execute_over_organizer_items_only: "Operations can be executed on Organizer::Items only",
    definition_must_be_a_proc: "Operation definition must be a Proc"
  }
end

class Organizer::OperationsCollectionException < ::Exception
  ERRORS = {
    invalid_item: "Invalid operations collection item. Must be Organizer:Operation only"
  }
end

class Organizer::OperationsManagerException < ::Exception
  ERRORS = {}
end

class Organizer::GroupException < ::Exception
  ERRORS = {
    invalid_item: "Invalid group collection item. Must be Organizer:Collection only",
    group_by_attr_not_present_in_collection: "group_by_attr is not present in collection Organizer::Items"
  }
end
