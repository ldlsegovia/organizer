require 'spec_helper'

describe Organizer::Operation::Collection do
  describe "#<<" do
    it "raises error trying to add non organizer operations to collection" do
      expect { subject << "not an organizer operation" }.to(
        raise_organizer_error(Organizer::Operation::CollectionException, :invalid_item))
    end

    it "adds Organizer::Operation::Item to collection" do
      proc = Proc.new {}
      operation = Organizer::Operation::Item.new(proc, :my_new_attribute)
      subject << operation
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Operation::Item)
    end

    it "raises error with repeated operation name" do
      skip
    end
  end
end
