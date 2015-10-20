module HelpfulVariables
  def let_item(_name)
    attributes = {
      int_attr1: 400,
      int_attr2: 266,
      float_attr: 4.684,
      string_attr: "Hi! I'm a String",
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

  def let_group_collection(_name, group_attr = :store_id)
    collection_name = "#{_name}_group_collection"
    let_collection(collection_name)
    let(_name) do
      groups_collection = Organizer::Group::Collection.new
      groups_collection << Organizer::Group::Item.new(group_attr)
      Organizer::Group::Builder.build(
        send(collection_name), groups_collection)
    end
  end
end
