require 'spec_helper'

describe OrganizedCollection do

  describe "#<<" do

    it "raises error trying to add non organized items to collection" do
      expect { subject << "not an organized item" }.to(
        raise_organizer_error(:invalid_organizer_collection_item))
    end

    it "adds OrganizedItem to collection" do
      subject << OrganizedItem.new
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(OrganizedItem)
    end

  end

end
