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

    let(_name) do
      Organizer::Item.new.define_attributes(attributes)
    end

    let("#{_name}_hash") do
      attributes
    end

    let("#{_name}_hash_keys") do
      attributes.keys
    end
  end

  def let_collection(_name)
    collection = [
      { attr1: 4, attr2: "Hi", attr3: 6, store_id: 1 },
      { attr1: 6, attr2: "Ciao", attr3: 4, store_id: 1 },
      { attr1: 84, attr2: "Hola", attr3: 16, store_id: 2 }
    ]

    let("raw_#{_name}") do
      collection
    end

    let(_name) do
      organizer_collection = Organizer::Collection.new

      collection.each do |item|
        organizer_collection << Organizer::Item.new.define_attributes(item)
      end

      organizer_collection
    end
  end
end
