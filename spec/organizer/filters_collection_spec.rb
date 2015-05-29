require 'spec_helper'

describe Organizer::FiltersCollection do
  describe "#<<" do
    it "raises error trying to add non organizer filters to collection" do
      expect { subject << "not an organizer filter" }.to(
        raise_organizer_error(Organizer::FiltersCollectionException, :invalid_item))
    end

    it "adds Organizer::Filter to collection" do
      proc = Proc.new {}
      filter = Organizer::Filter.new(proc)
      subject << filter
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Filter)
    end
  end
end
