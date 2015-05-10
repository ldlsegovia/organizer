class Organizer::Exception < Exception
  ERRORS = {
    invalid_organizer_name: "Invalid organizer name. Needs to be a constantizable string"
  }
end
