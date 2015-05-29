require 'spec_helper'

describe Organizer::Collection do
  let_raw_collection(:raw_collection)

  describe "#<<" do
    it "raises error trying to add non organizer items to collection" do
      expect { subject << "not an organizer item" }.to(
        raise_organizer_error(Organizer::CollectionException, :invalid_item))
    end

    it "adds Organizer::Item to collection" do
      subject << Organizer::Item.new
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Item)
    end
  end

  describe "#fill" do
    it "raises error when collection method does not return an Array" do
      expect { Organizer::Collection.new.fill("I'm not an array" ) }.to(
        raise_organizer_error(Organizer::CollectionException, :invalid_collection_structure))
    end

    it "raises error with collection method not returning a Array of Hashes" do
      expect { Organizer::Collection.new.fill(["I'm not a hash"]) }.to(
        raise_organizer_error(Organizer::CollectionException, :invalid_collection_item_structure))
    end

    it "returns an Organizer::Collection instance" do
      collection = Organizer::Collection.new.fill(raw_collection)
      expect(collection).to be_a(Organizer::Collection)
      expect(collection.count).to eq(3)
    end
  end
end
