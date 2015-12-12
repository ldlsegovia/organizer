require 'spec_helper'

describe Organizer::Operation::GroupExecutor do
  subject { Organizer::Operation::GroupExecutor }
  before { @operations = Organizer::Operation::Collection.new }

  describe "#execute_based_on_children" do
    let_group_collection(:gender, :gender)

    before do
      @operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      definitions = Organizer::Group::DefinitionsCollection.new
      definition = definitions.add_definition(:gender)
      @operations.each { |operation| definition.add_memo_operation(operation) }
      @result = subject.execute_based_on_children(definitions, gender_group_collection, gender)
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
