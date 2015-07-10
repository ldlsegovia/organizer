require 'spec_helper'

describe Organizer::Group::Collection do
  describe "#<<" do
    it "raises error trying to add non organizer groups to collection" do
      expect { subject << "not an organizer group" }.to(
        raise_organizer_error(Organizer::Group::CollectionException, :invalid_item))
    end

    it "adds Organizer::Group::Item to collection" do
      subject << Organizer::Group::Item.new(Proc.new {})
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Group::Item)
    end
  end

  describe "#group_by_name" do
    before do
      subject << Organizer::Group::Item.new(:group1)
      subject << Organizer::Group::Item.new(:group2)
    end

    it "returns existent group" do
      [:group1, "group2"].each do |group_name|
        expect(subject.group_by_name(group_name).name).to eq(group_name.to_sym)
      end
    end

    it "returns nil with inexistent group" do
      expect(subject.group_by_name(:invalid_name)).to be_nil
    end
  end
end
