class Organizer::Exception < Exception
  ERRORS = {
    invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string",
    undefined_collection_method: "Undefined collection method. You need to add collection(){} into Organizer::Template.define block",
    invalid_collection_structure: "Invalid collection structure. Must be Array",
    invalid_collection_item_structure: "Invalid collection item structure. Must be a Hash",
    organized_item_must_be_a_hash: "_hash parameter must be a Hash",
    invalid_organized_item_attribute: "Invalid _hash key. A key can contain: alphanumeric, space, underscore and hypen characters",
    method_redefinition_not_allowed: "The _hash keys can't be named as pre-existent methods",
    invalid_organizer_collection_item: "Invalid item for collection. Must be Organizer::Item instance",
    filter_definition_must_be_a_proc: "Filter definition must be a Proc",
    filter_applied_on_organizer_items_only: "Filters can be applied on Organizer::Items only",
    filter_definition_must_return_boolean: "Invalid filter definition result. The definition bock call must return a boolean value",
    invalid_filter_collection_item: "Invalid filter collection item. Must be Organizer:Filter only",
    invalid_operations_collection_item: "Invalid operations collection item. Must be Organizer:Operation only",
    blank_operation_name: "Operation name param is mandatory",
    operations_over_organizer_items_only: "Operations can be executed on Organizer::Items only"
  }
end
