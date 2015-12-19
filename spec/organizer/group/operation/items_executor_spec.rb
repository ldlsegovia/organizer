require 'spec_helper'

describe Organizer::Group::Operation::ItemsExecutor do
  subject { Organizer::Group::Operation::ItemsExecutor }
  let_group(:gender, true, :gender, :site_id)

  describe "#execute" do
    before do
      simple_operations = Organizer::Operation::Collection.new

      simple_operations.add_simple_item(:age_diff) do |item|
        item.greater_age - item.lower_age
      end

      simple_operations.add_simple_item(:double_age_diff) do |item|
        item.age_diff * 2
      end

      gender_definition.item_operations = simple_operations
      @result = subject.execute(gender_definitions, gender)
    end

    it "returns a group collection" do
      expect(@result.size).to eq(2)
      expect(@result).to be_a(Organizer::Group::Collection)
    end

    it "returns group items with new attribute" do
      expect(@result.first.age_diff).to eq(57)
      expect(@result.last.age_diff).to eq(31)
    end

    it "executes operations on items with definition only" do
      item = @result.first.first
      expect(item).to be_a(Organizer::Group::Item)
      expect(item).to_not respond_to(:age_diff)
      expect(item).to_not respond_to(:double_age_diff)
    end

    it "executes operations based on generated operations" do
      expect(@result.first.double_age_diff).to eq(114)
      expect(@result.last.double_age_diff).to eq(62)
    end
  end
end
