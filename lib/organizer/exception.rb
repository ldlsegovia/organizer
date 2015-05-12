class Organizer::Exception < Exception
  ERRORS = {
    invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string",
    undefined_collection_method: "Undefined collection method. You need to add collection(){} into Organizer.define block",
    invalid_collection_structure: "Invalid collection structure. Must be Array",
    invalid_collection_item_structure: "Invalid collection item structure. Must be a Hash"
  }
end
