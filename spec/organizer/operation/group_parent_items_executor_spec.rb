require 'spec_helper'

describe Organizer::Group::Operation::ParentItemsExecutor do
  subject { Organizer::Group::Operation::ParentItemsExecutor }
  let_group_collection(:gender, :gender)

  before do
    @definitions = Organizer::Group::DefinitionsCollection.new
    @definition = @definitions.add_definition(:gender)
  end

  describe "#execute_based_on_children" do
    before do
      operations = Organizer::Operation::Collection.new

      operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      @definition.children_based_operations = operations
      @result = subject.execute(@definitions, gender_group_collection, gender)
    end

    it "returns a group collection" do
      expect(@result.size).to eq(2)
      expect(@result).to be_a(Organizer::Group::Collection)
    end

    it "returns group items with new attribute" do
      expect(@result.first.age_sum).to eq(192)
      expect(@result.last.age_sum).to eq(130)
    end
  end
end
