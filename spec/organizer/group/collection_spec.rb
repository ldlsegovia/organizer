require 'spec_helper'

describe Organizer::Group::Collection do
  describe "#add_group" do
    it "adds new group" do
      expect { subject.add_group(:store_id) {} }.to change { subject.count }.from(0).to(1)
    end

    it "uses name to set group_by_attr if attr is nil" do
      group = subject.add_group(:site_id) {}
      expect(group.item_name).to eq(:site_id)
      expect(group.group_by_attr).to eq(:site_id)
    end

    it "uses different name and group_by_attr" do
      group = subject.add_group(:site, :site_id) {}
      expect(group.item_name).to eq(:site)
      expect(group.group_by_attr).to eq(:site_id)
    end

    context "with parent" do
      before do
        subject.add_group(:site, :site_id) {}
      end

      it "raises error with invalid parent" do
        expect { subject.add_group(:section, :section_id, :invalid_parent) {} }.to(
          raise_organizer_error(Organizer::Group::CollectionException, :invalid_parent))
      end

      it "sets parent name into child group" do
        group = subject.add_group(:section, :section_id, :site) {}
        expect(group.parent_name).to eq(:site)
      end
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
