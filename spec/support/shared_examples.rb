shared_examples :attributes_handler do |klass, error_class|
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
      [nil, ["value1", "value2"], "some string", 1].each do |invalid_hash|
        expect { subject.define_attributes(invalid_hash) }.to(
          raise_organizer_error(error_class, :must_be_a_hash))
      end
    end

    it "converts each attribute hash into klass instance attribute readers" do
      subject.define_attributes(valid_attributes)
      valid_attributes.each do |attribute, value|
        expect(subject).to respond_to(attribute)
      end
    end

    it "sets dynamic attributes with hash values" do
      subject.define_attributes(valid_attributes)
      valid_attributes.each do |attribute, value|
        expect(subject.send(attribute)).to eq(value)
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

      subject.define_attributes(hash)
      expect(subject).to respond_to(:with_camel_case)
      expect(subject).to respond_to(:with_hypen_characters)
      expect(subject).to respond_to(:uppercase_characters)
      expect(subject).to respond_to(:underscore_characters)
      expect(subject).to respond_to(:num3r1c_ch4r4ct3rs)
    end

    it "returns error with invalid hash keys" do
      invalid_hashes = [
        { "inv@lid_characters" => false },
        { "in\/alid_characters" => false },
        { "invalid_(hara(ters" => false },
        { "invalid:characters" => false }
      ]

      invalid_hashes.each do |invalid_hash|
        expect { subject.define_attributes(invalid_hash) }.to(
          raise_organizer_error(error_class, :invalid_attribute_key))
      end
    end

    it "preserves attribute's data types" do
      subject.define_attributes(valid_attributes)
      expect(subject.first_name).to be_a(String)
      expect(subject.last_name).to be_a(String)
      expect(subject.birth_date).to be_a(Date)
      expect(subject.cash).to be_a(Float)
    end

    it "defines attributes inside singleton class" do
      obj1 = klass.new
      obj1.define_attributes({method_for_obj1: "I'm a method for obj1"})
      obj2 = klass.new
      obj2.define_attributes({method_for_obj2: "I'm a method for obj2"})
      expect(obj1).to respond_to(:method_for_obj1)
      expect(obj1).not_to respond_to(:method_for_obj2)
      expect(obj2).not_to respond_to(:method_for_obj1)
      expect(obj2).to respond_to(:method_for_obj2)
    end
  end

  describe "#attribute_names" do
    it "returns hash keys matching attribute names exactly" do
      obj = klass.new
      obj.define_attributes(valid_attributes)
      expect(obj.attribute_names).to match_array(valid_attributes.keys)
    end
  end

  describe "#clone_attributes" do
    let_item(:obj_to_clone)

    before do
      @obj = klass.new
      @obj.clone_attributes(obj_to_clone)
    end

    it "returns error if object to clone has not Organizer::AttributesHandler mixin" do
      expect { @obj.clone_attributes("not a valid object") }.to(
        raise_organizer_error(error_class, :attributes_handler_not_included))
    end

    it "copies attributes from param" do
      obj_to_clone_hash_keys.each { |attribute, value| expect(@obj).to respond_to(attribute) }
    end
  end
end
