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

    let(_name) { Organizer::Item.new.define_attributes(attributes) }
    let("#{_name}_hash") { attributes }
    let("#{_name}_hash_keys") { attributes.keys }
  end

  def let_collection(_name)
    collection = [
      { age: 22, name: "Juan Manuel", site_id: 1, store_id: 1, gender: "M", savings: 20.50 },
      { age: 31, name: "Leandro", site_id: 1, store_id: 1, gender: "M", savings: 15.50 },
      { age: 64, name: "Susana", site_id: 2, store_id: 2, gender: "F", savings: 30.00 },
      { age: 65, name: "Rodolfo", site_id: 2, store_id: 2, gender: "M", savings: 50.20 },
      { age: 33, name: "Virginia", site_id: 2, store_id: 3, gender: "F", savings: 70.10 },
      { age: 8, name: "Francisco", site_id: 2, store_id: 3, gender: "M", savings: 2.50 },
      { age: 31, name: "Gustavo", site_id: 3, store_id: 4, gender: "M", savings: 40.50 },
      { age: 33, name: "Gabriela", site_id: 3, store_id: 4, gender: "F", savings: 45.50 },
      { age: 35, name: "Javier", site_id: 3, store_id: 5, gender: "M", savings: 25.50 }
    ]

    let("raw_#{_name}") { collection }

    let(_name) do
      organizer_collection = Organizer::Collection.new

      collection.each do |item|
        organizer_collection << Organizer::Item.new.define_attributes(item)
      end

      organizer_collection
    end
  end
end
