shared_examples :collection_item do
  describe "#has_name?" do
    it "returns true when item has name param" do
      expect(item.has_name?("item_name")).to be_truthy
      expect(item.has_name?(:item_name)).to be_truthy
    end

    it "returns false when item has not name param" do
      expect(item.has_name?("invalid")).to be_falsy
    end
  end
end
