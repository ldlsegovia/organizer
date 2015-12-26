require 'spec_helper'

describe Organizer::Group::Collection do
  describe "#add" do
    it "adds new group" do
      expect { subject.add(:store_id) {} }.to change { subject.count }.from(0).to(1)
    end

    it "uses name to set group_by_attr if attr is nil" do
      group = subject.add(:site_id) {}
      expect(group.item_name).to eq(:site_id)
      expect(group.group_by_attr).to eq(:site_id)
    end

    it "uses different name and group_by_attr" do
      group = subject.add(:site, :site_id) {}
      expect(group.item_name).to eq(:site)
      expect(group.group_by_attr).to eq(:site_id)
    end
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Group::Collection.new }
    let!(:collection_exception_class) { Organizer::Group::CollectionException }
    let!(:item) { Organizer::Group::Item.new(:item_name) }
    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Group::Collection.new }
    it_should_behave_like(:explainer)
  end
end
