require 'spec_helper'

describe Organizer::Item do
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
          raise_organizer_error(Organizer::ItemException, :must_be_a_hash))
      end
    end

    it "converts each attribute hash into Organizer::Item instance attribute readers" do
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

    it "it returs error with invalid hash keys" do
      invalid_hashes = [
        { "inv@lid_characters" => false },
        { "in\/alid_characters" => false },
        { "invalid_(hara(ters" => false },
        { "invalid:characters" => false }
      ]

      invalid_hashes.each do |invalid_hash|
        expect { subject.define_attributes(invalid_hash) }.to(
          raise_organizer_error(Organizer::ItemException, :invalid_attribute_key))
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
      item1 = Organizer::Item.new
      item1.define_attributes({method_for_item1: "I'm a method for item1"})
      item2 = Organizer::Item.new
      item2.define_attributes({method_for_item2: "I'm a method for item2"})
      expect(item1).to respond_to(:method_for_item1)
      expect(item1).not_to respond_to(:method_for_item2)
      expect(item2).not_to respond_to(:method_for_item1)
      expect(item2).to respond_to(:method_for_item2)
    end
  end

  describe "#attribute_names" do
    let_item(:item)

    it "returns hash keys matching attribute names exactly" do
      expect(item.attribute_names).to match_array(item_hash_keys)
    end
  end
end
