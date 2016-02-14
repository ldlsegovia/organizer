shared_examples :attributes_handler do
  let(:valid_attributes) do
    {
      first_name: "Leandro",
      last_name: "Segovia",
      birth_date: Date.parse("04-06-1984"),
      cash: 200.58
    }
  end

  describe "#define_attributes" do
    it "returns error with invalid hash param" do
      [["value1", "value2"], "some string", 1].each do |invalid_hash|
        expect { instance.define_attributes(invalid_hash) }.to(
          raise_organizer_error(error_class, :must_respond_to_hash))
      end
    end

    it "converts each attribute hash into class instance attribute readers" do
      instance.define_attributes(valid_attributes)
      valid_attributes.each do |attribute, _|
        expect(instance).to respond_to(attribute)
      end
    end

    it "sets dynamic attributes with hash values" do
      instance.define_attributes(valid_attributes)
      valid_attributes.each do |attribute, value|
        expect(instance.send(attribute)).to eq(value)
      end
    end

    it "converts hash keys to snake_case methods" do
      hash = {
        "withCamelCase" => true,
        "with-hypen-characters" => true,
        "UPPERCASE_CHARACTERS" => true,
        "spaces   are   allowed" => true,
        "underscore_characters" => true,
        "num3r1c_ch4r4ct3rs" => true,
      }

      instance.define_attributes(hash)
      expect(instance).to respond_to(:with_camel_case)
      expect(instance).to respond_to(:with_hypen_characters)
      expect(instance).to respond_to(:uppercase_characters)
      expect(instance).to respond_to(:underscore_characters)
      expect(instance).to respond_to(:num3r1c_ch4r4ct3rs)
    end

    it "returns error with invalid hash keys" do
      invalid_hashes = [
        { "inv@lid_characters" => false },
        { "in\/alid_characters" => false },
        { "invalid_(hara(ters" => false },
        { "invalid:characters" => false }
      ]

      invalid_hashes.each do |invalid_hash|
        expect { instance.define_attributes(invalid_hash) }.to(
          raise_organizer_error(error_class, :invalid_attribute_key))
      end
    end

    it "preserves attribute's data types" do
      instance.define_attributes(valid_attributes)
      expect(instance.first_name).to be_a(String)
      expect(instance.last_name).to be_a(String)
      expect(instance.birth_date).to be_a(Date)
      expect(instance.cash).to be_a(Float)
    end

    it "raises error trying to redefine attributes" do
      instance.define_attributes(valid_attributes)
      expect { instance.define_attributes(valid_attributes) }.to(
        raise_organizer_error(error_class, :attr_already_defined))
    end

    it "works with objects implementing to_h method" do
      struct = OpenStruct.new(first_name: "Leandro")
      instance.define_attributes(struct)
      expect(instance.first_name).to eq("Leandro")
    end
  end

  describe "#attribute_names" do
    it "returns hash keys matching attribute names exactly" do
      instance.define_attributes(valid_attributes)
      expect(instance.attribute_names).to match_array(valid_attributes.keys)
    end
  end

  describe "#clone_attributes" do
    let_item(:obj_to_clone)
    before { instance.clone_attributes(obj_to_clone) }

    it "returns error if object to clone has not Organizer::AttributesHandler mixin" do
      expect { instance.clone_attributes("not a valid object") }.to(
        raise_organizer_error(error_class, :attributes_handler_not_included))
    end

    it "copies attributes from param" do
      obj_to_clone_hash_keys.each { |attribute, _| expect(instance).to respond_to(attribute) }
    end
  end
end
