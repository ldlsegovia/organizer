require 'spec_helper'

describe Organizer::Operation::Executor do
  subject { Organizer::Operation::Executor }
  before { @operations = Organizer::Operation::Collection.new }

  describe "#execute" do
    let_collection(:collection)
    before { @operations.add_simple_operation(:result_attr) { |item| item.age * 2 } }

    it "returns the whole collection" do
      result = subject.execute(@operations, collection)
      expect(result.size).to eq(9)
      expect(result).to be_a(Organizer::Source::Collection)
    end

    it "returns collection items with new attribute" do
      expect(subject.execute(@operations, collection).first.result_attr).to eq(44)
    end

    context "with nested operations" do
      before do
        @operations.add_simple_operation(:newer_result_attr) { |item| item.result_attr * 2 }
        @operations.add_simple_operation(:newest_result_attr) { |item| item.newer_result_attr * 2 }
        @operations.add_simple_operation(:the_newest_result_attr) { |item| item.newest_result_attr * 2 }
      end

      it "returns collection items with new attribute" do
        result = subject.execute(@operations, collection).first
        expect(result.newer_result_attr).to eq(88)
        expect(result.newest_result_attr).to eq(176)
        expect(result.the_newest_result_attr).to eq(352)
      end

      context "with invalid item attribute" do
        before { @operations.add_simple_operation(:another_attr) { |item| item.invalid_attr * 2 } }
        before { @operations.add_simple_operation(:some_attr) { |item| item.some_invalid_attr * 2 } }

        it "raise exception" do
          expect { subject.execute(@operations, collection) }.to(
            raise_error(Organizer::Operation::ExecutorException))
        end
      end
    end
  end

  describe "#execute" do
    let_group_collection(:gender, :gender)

    before do
      @operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end
    end

    it "returns a group collection" do
      result = subject.execute(@operations, gender_group_collection, gender)
      expect(result.size).to eq(2)
      expect(result).to be_a(Organizer::Group::Collection)
    end

    it "returns group items with new attribute" do
      result = subject.execute(@operations, gender_group_collection, gender)
      expect(result.first.age_sum).to eq(192)
      expect(result.last.age_sum).to eq(130)
    end
  end
end
