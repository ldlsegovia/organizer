require 'spec_helper'

describe Organizer::GroupsCollection do
  describe "#<<" do
    it "raises error trying to add non organizer groups to collection" do
      expect { subject << "not an organizer group" }.to(
        raise_organizer_error(Organizer::GroupsCollectionException, :invalid_item))
    end

    it "adds Organizer::Group to collection" do
      subject << Organizer::Group.new(Proc.new {})
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Group)
    end
  end
end
