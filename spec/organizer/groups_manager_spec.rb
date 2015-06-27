require 'spec_helper'

describe Organizer::GroupsManager do
  let_collection(:collection)

  describe "#add_group" do
    it "adds new group" do
      expect(subject.send(:groups).count).to eq(0)
      subject.add_group(:store_id) {}
      expect(subject.send(:groups).count).to eq(1)
    end

    it "uses name to set group_by_attr if attr is nil" do
      group = subject.add_group(:site_id) {}
      expect(group.name).to eq(:site_id)
      expect(group.group_by_attr).to eq(:site_id)
    end

    it "raises error with repeated operation name" do
      skip
    end
  end
end