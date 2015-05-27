module HelpfulVariables
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
      collection << Organizer::Item.new.define_attributes({ attr1: 4, attr2: "Hi", attr3: 6 })
      collection << Organizer::Item.new.define_attributes({ attr1: 6, attr2: "Ciao", attr3: 4 })
      collection << Organizer::Item.new.define_attributes({ attr1: 84, attr2: "Hola", attr3: 16 })
      collection
    end
  end
end
