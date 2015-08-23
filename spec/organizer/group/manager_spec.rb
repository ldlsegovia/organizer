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

    context "with parent" do
      before do
        subject.add_group(:site, :site_id) {}
      end

      it "raises error with invalid parent" do
        expect { group = subject.add_group(:section, :section_id, :invalid_parent) {} }.to(
          raise_organizer_error(Organizer::Group::ManagerException, :invalid_parent))
      end

      it "sets parent name into child group" do
        group = subject.add_group(:section, :section_id, :site) {}
        expect(group.parent_name).to eq(:site)
      end
    end
  end

  describe "#build" do
    let_collection(:collection)

    context "with a single group" do
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

      before { @group = subject.build(collection, { group_by: :store }) }

      it { expect(@group.size).to eq(5) }
      it { expect(@group).to be_a(Organizer::Group::Collection) }
      it { @group.each { |group| expect(group).to be_a(Organizer::Group::Item) } }
    end

    context "with nested groups" do

      shared_examples :nested_group do
        it { expect(@group.size).to eq(2) }
        it { expect(@group).to be_a(Organizer::Group::Collection) }

        it { expect(@group.first).to be_a(Organizer::Group::Item) }
        it { expect(@group.first.group_name).to eq(:gender) }
        it { expect(@group.first.size).to eq(3) }

        it { expect(@group.first.first).to be_a(Organizer::Group::Item) }
        it { expect(@group.first.first.group_name).to eq(:site) }
        it { expect(@group.first.first.size).to eq(1) }

        it { expect(@group.first.first.first).to be_a(Organizer::Group::Item) }
        it { expect(@group.first.first.first.group_name).to eq(:store) }
        it { expect(@group.first.first.first.size).to eq(2) }

        it { expect(@group.first.first.first.first).to be_a(Organizer::Source::Item) }
        it { expect(@group.first.first.first.first.gender).to eq("M") }
        it { expect(@group.first.first.first.first.site_id).to eq(1) }
        it { expect(@group.first.first.first.first.store_id).to eq(1) }
      end

      context "nested through params" do
        before do
          subject.add_group(:gender)
          subject.add_group(:site, :site_id)
          subject.add_group(:store, :store_id)
          @group = subject.build(collection, { group_by: [:gender, :site, :store] } )
        end

        it_should_behave_like(:nested_group)
      end

      context "nested on definition" do
        before do
          subject.add_group(:gender)
          subject.add_group(:site, :site_id, :gender)
          subject.add_group(:store, :store_id, :site)
          @group = subject.build(collection, { group_by: :gender } )
        end

        it_should_behave_like(:nested_group)
      end
    end
  end
end
