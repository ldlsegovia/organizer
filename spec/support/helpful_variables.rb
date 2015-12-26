module HelpfulVariables
  def let_item(_name)
    attributes = {
      int_attr1: 400,
      int_attr2: 266,
      float_attr: 4.684,
      string_attr: "Hi! Im a String",
      date_attr: "04/06/1984".to_date,
      datetime_attr: "04/06/1984 06:06:06".to_datetime
    }

    let(_name) { Organizer::Source::Item.new.define_attributes(attributes) }
    let("#{_name}_hash") { attributes }
    let("#{_name}_hash_keys") { attributes.keys }
  end

  def let_collection(_name)
    collection = [
      { age: 22, first_name: "Juan Manuel", site_id: 1, store_id: 1, gender: "M", savings: 20.50 },
      { age: 31, first_name: "Leandro", site_id: 1, store_id: 1, gender: "M", savings: 15.50 },
      { age: 64, first_name: "Susana", site_id: 2, store_id: 2, gender: "F", savings: 30.00 },
      { age: 65, first_name: "Rodolfo", site_id: 2, store_id: 2, gender: "M", savings: 50.20 },
      { age: 33, first_name: "Virginia", site_id: 2, store_id: 3, gender: "F", savings: 70.10 },
      { age: 8, first_name: "Francisco", site_id: 2, store_id: 3, gender: "M", savings: 2.50 },
      { age: 31, first_name: "Gustavo", site_id: 3, store_id: 4, gender: "M", savings: 40.50 },
      { age: 33, first_name: "Gabriela", site_id: 3, store_id: 4, gender: "F", savings: 45.50 },
      { age: 35, first_name: "Javier", site_id: 3, store_id: 5, gender: "M", savings: 25.50 }
    ]

    let("raw_#{_name}") { collection }

    let(_name) do
      collection.inject(Organizer::Source::Collection.new) do |organizer_collection, item|
        organizer_collection << Organizer::Source::Item.new.define_attributes(item)
      end
    end
  end

  def let_group(_identifier, _with_operations = true, *_groups_hierarchy)
    source_collection_identifier = "#{_identifier}_source_collection"
    let_collection(source_collection_identifier)

    definitions_collection_identifier = "#{_identifier}_definitions"
    let!("#{_identifier}_definitions") { Organizer::Group::DefinitionsCollection.new }

    _groups_hierarchy.each do |group_name|
      group_definition_identifier = "#{group_name}_definition"

      let!(group_definition_identifier) do
        definition = send(definitions_collection_identifier).add(group_name)
        self.class.add_operations_to_group_definition(definition) if _with_operations
        definition
      end
    end

    let!(_identifier) do
      result = Organizer::Group::Builder.build(send(source_collection_identifier),
        send(definitions_collection_identifier).groups_from_definitions)

      return result unless _with_operations

      Organizer::Group::Operation::ParentItemsExecutor.execute(
        send(definitions_collection_identifier), send(source_collection_identifier), result)
    end
  end

  def add_operations_to_group_definition(_definition)
    parent_operations = Organizer::Operation::Collection.new

    parent_operations.add(:lower_age) do |parent, item|
      parent.lower_age = item.age if parent.lower_age.nil?
      parent.lower_age < item.age ? parent.lower_age : item.age
    end

    parent_operations.add(:greater_age, initial_value: 0) do |parent, item|
      parent.greater_age > item.age ? parent.greater_age : item.age
    end

    _definition.parent_item_operations = parent_operations
  end
end
