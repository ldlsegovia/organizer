require 'spec_helper'

describe Organizer::Group::Operation::ItemsExecutor do
  subject { Organizer::Group::Operation::ItemsExecutor }
  let_group_collection(:gender, :gender)

  describe "#execute" do
    before do
      @definitions = Organizer::Group::DefinitionsCollection.new
      @definition = @definitions.add_definition(:gender)
      parent_operations = Organizer::Operation::Collection.new

      parent_operations.add_group_parent_item(:lower_age, nil) do |parent, item|
        parent.lower_age = item.age if parent.lower_age.nil?
        parent.lower_age < item.age ? parent.lower_age : item.age
      end

      parent_operations.add_group_parent_item(:greater_age) do |parent, item|
        parent.greater_age > item.age ? parent.greater_age : item.age
      end

      simple_operations = Organizer::Operation::Collection.new

      simple_operations.add_simple_item(:age_diff) do |item|
        item.greater_age - item.lower_age
      end

      simple_operations.add_simple_item(:double_age_diff) do |item|
        item.age_diff * 2
      end

      @definition.parent_item_operations = parent_operations
      @definition.item_operations = simple_operations

      result = Organizer::Group::Operation::ParentItemsExecutor.execute(
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
