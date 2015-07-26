require 'spec_helper'

describe Organizer::Group::Manager do
  let_collection(:collection)

  describe "#add_group" do
    it "adds new group" do
      expect { subject.add_group(:store_id) {} }.to change {
        subject.send(:groups).count }.from(0).to(1)
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
  end

  describe "#build" do
    let_collection(:collection)
    before { subject.add_group(:store, :store_id) }

    it "returns ungrouped collection trying to group by nil" do
      expect(subject.build(collection, { group_by: nil })).to eq(collection)
    end

    it "returns error trying to group by unknown group" do
      expect { subject.build(collection, { group_by: :unknown_group }) }.to(
        raise_organizer_error(Organizer::Group::ManagerException, :unknown_group_given))

      expect { subject.build(collection, { group_by: [:unknown_group] }) }.to(
        raise_organizer_error(Organizer::Group::ManagerException, :unknown_group_given))
    end

    it "returns collection when group_by option is no present" do
      expect(subject.build(collection, {})).to eq(collection)
    end

    context "with a single group" do
      before { @group = subject.build(collection, { group_by: :store }) }

      it { expect(@group.size).to eq(5) }
      it { expect(@group).to be_a(Organizer::Group::Collection) }
      it { @group.each { |group| expect(group).to be_a(Organizer::Group::Item) } }
    end

    context "with nested groups" do
      before do
        subject.add_group(:site, :site_id)
        subject.add_group(:gender)
        @group = subject.build(collection, { group_by: [:gender, :site, :store] } )
      end

      it { skip }
    end
  end
end
