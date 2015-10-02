require 'spec_helper'

describe Organizer::Group::Builder do
  let_collection(:collection)
  subject { Organizer::Group::Builder }

  describe "#build" do
    context "grouping by attribute" do
      before do
        @groups = Organizer::Group::Collection.new
        @groups.add_group(:store, :store_id)
      end

      it "returns empty group with empty source" do
        result = subject.build(Organizer::Source::Collection.new, @groups, :store)
        expect(result).to be_a(Organizer::Group::Collection)
        expect(result.size.zero?).to be_truthy
      end

      it "returns ungrouped collection trying to group by nil" do
        expect(subject.build(collection, @groups, nil)).to eq(collection)
      end

      it "returns error trying to group by unknown group" do
        expect { subject.build(collection, @groups, :unknown_group) }.to(
          raise_organizer_error(Organizer::Group::BuilderException, :unknown_group_given))
      end

      context "with grouped collection" do
        before { @group = subject.build(collection, @groups, :store) }

        it { expect(@group.size).to eq(5) }
        it { expect(@group).to be_a(Organizer::Group::Collection) }
        it { @group.each { |group| expect(group).to be_a(Organizer::Group::Item) } }

        it "contains items inside group items" do
          one = @group.first
          two = @group.last
          expect(one).to be_a(Organizer::Group::Item)
          expect(two).to be_a(Organizer::Group::Item)
          expect(one.size).to eq(2)
          expect(two.size).to eq(1)
          expect(one.first).to be_a(Organizer::Source::Item)
          expect(one.last).to be_a(Organizer::Source::Item)
          expect(two.first).to be_a(Organizer::Source::Item)
        end
      end
    end

    context "grouping by condition" do
      before do
        @groups = Organizer::Group::Collection.new
        @groups.add_group(:age_greater_than_33, "item.age > 33")
        @group = subject.build(collection, @groups, :age_greater_than_33)
      end

      it { expect(@group.size).to eq(2) }
      it { expect(@group).to be_a(Organizer::Group::Collection) }

      it { expect(@group.first).to be_a(Organizer::Group::Item) }
      it { expect(@group.first.group_name).to eq(:age_greater_than_33) }
      it { expect(@group.first.size).to eq(6) }

      it { expect(@group.last).to be_a(Organizer::Group::Item) }
      it { expect(@group.last.group_name).to eq(:age_greater_than_33) }
      it { expect(@group.last.size).to eq(3) }
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
          groups = Organizer::Group::Collection.new
          groups.add_group(:gender)
          groups.add_group(:site, :site_id)
          groups.add_group(:store, :store_id)
          @group = subject.build(collection, groups, [:gender, :site, :store])
        end

        it_should_behave_like(:nested_group)
      end

      context "nested on definition" do
        before do
          groups = Organizer::Group::Collection.new
          groups.add_group(:gender)
          groups.add_group(:site, :site_id, :gender)
          groups.add_group(:store, :store_id, :site)
          @group = subject.build(collection, groups, :gender)
        end

        it_should_behave_like(:nested_group)
      end
    end
  end
end
