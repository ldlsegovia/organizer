require 'spec_helper'

describe Organizer::Group::Collection do
  describe "#build" do
    let_collection(:collection)
    before { @group = Organizer::Group::Item.new(:store_id) }

    it "raises error if collection items have not group_by_attr" do
      group = Organizer::Group::Item.new(:undefined_attr)
      expect { subject.build(collection, [group]) }.to(
        raise_organizer_error(Organizer::Group::CollectionException, :group_by_attr_not_present_in_collection))
    end

    it "returns empty group collection" do
      expect(subject.build(Organizer::Source::Collection.new, @group)).to be_a(Organizer::Group::Collection)
    end

    context "with a built a group" do
      before { @result = Organizer::Group::Collection.new.build(collection, [@group]) }

      it "returns same group with valid collection" do
        expect(@result).to be_a(Organizer::Group::Collection)
      end

      it "contains group items" do
        expect(@result.size).to eq(5)
        0.upto(4).each { |i| expect(@result[i]).to be_a(Organizer::Group::Item) }
      end

      it "contains items inside group items" do
        one = @result.first
        two = @result.last
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
