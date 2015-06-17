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

  def let_raw_collection(_name)
    let(_name) do
      [
        { attr1: 4, attr2: "Hi", attr3: 6 },
        { attr1: 6, attr2: "Ciao", attr3: 4 },
        { attr1: 84, attr2: "Hola", attr3: 16 }
      ]
    end
  end

  def let_organizer_collection(_name)
    let(_name) do
      collection = Organizer::Collection.new
      collection << Organizer::Item.new.define_attributes({ attr1: 4, attr2: "Hi", attr3: 6, store_id: 1 })
      collection << Organizer::Item.new.define_attributes({ attr1: 6, attr2: "Ciao", attr3: 4, store_id: 1 })
      collection << Organizer::Item.new.define_attributes({ attr1: 84, attr2: "Hola", attr3: 16, store_id: 2 })
      collection
    end
  end
end
