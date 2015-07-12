shared_examples :collection do
  describe "#<<" do
    it "raises error trying to add invalid item to collection" do
      expect { collection << "not an organizer item" }.to(
        raise_organizer_error(collection_exception_class, :invalid_item))
    end

    it "adds valid item to collection" do
      collection << item
      expect(collection.size).to eq(1)
      expect(collection.first).to be_a(item.class)
    end

    it "raises error trying to add repeated item name" do
      skip
    end
  end

  describe "#find_by_name" do
    before { collection << item }

    it "returns existent item" do
      expect(collection.find_by_name(:item_name).name).to eq(:item_name)
    end

    it "returns nil with inexistent item" do
      expect(collection.find_by_name(:invalid_name)).to be_nil
    end
  end

  describe "#select_items" do
    context "with non existent items collection" do
      it "returns selected items" do
        result = collection.select_items([])
        expect(result.size).to eq(0)
      end
    end

    context "with existent items collection" do
      before { collection << item }

      it "returns selected items" do
        result = collection.select_items([:item_name])
        expect(result).to be_a(Array)
        expect(result.size).to eq(1)
        expect(result.first.name).to eq(:item_name)
      end

      it "returns empty items collection with invalid item names" do
        ["", [], nil, "bla", 1].each do |names|
          result = collection.select_items(names)
          expect(result).to be_a(Array)
          expect(result.size).to eq(0)
        end
      end
    end
  end

  describe "#reject_items" do
    before { collection << item }

    it "returns non rejected items" do
      result = collection.reject_items([:item_name])
      expect(result.size).to eq(0)
    end

    it "returns all items collection with invalid item names" do
      ["", [], nil, "bla", 1].each do |names|
        result = collection.reject_items(names)
        expect(result).to be_a(collection.class)
        expect(result.size).to eq(1)
      end
    end
  end
end
