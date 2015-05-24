require 'spec_helper'

describe Organizer::Collection do

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

end
