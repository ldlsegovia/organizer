require 'spec_helper'

describe Organizer::Group::DefinitionsCollection do
  describe "#add_definition" do
    it "adds new group definition" do
      expect { subject.add_definition(:store_id) }.to change { subject.count }.from(0).to(1)
    end
  end

  describe "#groups_from_definitions" do
    before do
      subject.add_definition(:gender)
      subject.add_definition(:store_id)
      @groups = subject.groups_from_definitions
    end

    it "returns groups collection" do
      expect(@groups).to be_a(Organizer::Group::Collection)
    end

    it "creates one group by definition" do
      expect(@groups.count).to eq(2)
      expect(@groups.first.item_name).to eq(subject.first.item_name)
      expect(@groups.second.item_name).to eq(subject.second.item_name)
    end
  end

  describe "#add_memo_operation" do
    before { subject.add_definition(:store_id) }

    it "adds new operation related with given group" do
      expect { subject.add_memo_operation(:store_id, :age_sum, 0, &-> {}) }.to(
        change(subject.memo_operations(:store_id), :count).from(0).to(1))
    end

    it "adds new operation passing operation instance" do
      operation = Organizer::Operation::Memo.new(Proc.new {}, :age_sum, 0)
      expect { subject.add_memo_operation(:store_id, operation) }.to(
        change(subject.memo_operations(:store_id), :count).from(0).to(1))
    end

    it "raises error trying to add operation to unknown definition" do
      expect { subject.add_memo_operation(:unknown_group, :age_sum, 0, &-> {}) }.to(
        raise_organizer_error(Organizer::Group::DefinitionsCollectionException, :definition_not_found))
    end
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Group::DefinitionsCollection.new }
    let!(:collection_exception_class) { Organizer::Group::DefinitionsCollectionException }
    let!(:item) { Organizer::Group::Definition.new(:item_name) }
    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Group::DefinitionsCollection.new }
    it_should_behave_like(:explainer)
  end
end
