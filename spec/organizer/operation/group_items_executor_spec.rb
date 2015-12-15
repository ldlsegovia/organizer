require 'spec_helper'

describe Organizer::Group::Operation::ItemsExecutor do
  subject { Organizer::Group::Operation::ItemsExecutor }
  let_group_collection(:gender, :gender)

  describe "#execute" do
    before do
      @definitions = Organizer::Group::DefinitionsCollection.new
      @definition = @definitions.add_definition(:gender)
      memo_operations = Organizer::Operation::Collection.new

      memo_operations.add_memo_operation(:lower_age, nil) do |memo, item|
        memo.lower_age = item.age if memo.lower_age.nil?
        memo.lower_age < item.age ? memo.lower_age : item.age
      end

      memo_operations.add_memo_operation(:greater_age) do |memo, item|
        memo.greater_age > item.age ? memo.greater_age : item.age
      end

      simple_operations = Organizer::Operation::Collection.new

      simple_operations.add_simple_operation(:age_diff) do |item|
        item.greater_age - item.lower_age
      end

      simple_operations.add_simple_operation(:double_age_diff) do |item|
        item.age_diff * 2
      end

      @definition.children_based_operations = memo_operations
      @definition.group_item_operations = simple_operations

      result = Organizer::Operation::GroupParentItemsExecutor.execute(
        @definitions, gender_group_collection, gender)
      @result = subject.execute(@definitions, result)
    end

    it "returns a group collection" do
      expect(@result.size).to eq(2)
      expect(@result).to be_a(Organizer::Group::Collection)
    end

    it "returns group items with new attribute" do
      expect(@result.first.age_diff).to eq(57)
      expect(@result.last.age_diff).to eq(31)
    end

    it "executes operations based on generated operations" do
      expect(@result.first.double_age_diff).to eq(114)
      expect(@result.last.double_age_diff).to eq(62)
    end
  end
end
