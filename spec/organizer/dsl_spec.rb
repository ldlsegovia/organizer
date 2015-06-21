require 'spec_helper'

describe Organizer::DSL do
  let(:dsl) { Organizer::DSL.new("my_organizer") {} }
  before { Object.send(:remove_const, :MyOrganizer) rescue nil }

  describe "#initialize" do
    it "creates a MyOrganizer class" do
      Organizer::DSL.new("my_organizer") {}
      expect(MyOrganizer.superclass).to be(Organizer::Base)
    end

    it "executes block in class context" do
      Organizer::DSL.new("my_organizer") do
        default_filter {}
      end

      expect(MyOrganizer.filters_manager.send(:default_filters).count).to eq(1)
    end

    it "raises error with invalid organizer name" do
      expect {Organizer::DSL.new("invalid*class<name") }.to(
        raise_organizer_error(Organizer::DSLException, :invalid_organizer_name))
    end

    it "raises error with nil organizer name" do
      expect { Organizer::DSL.new(nil) }.to(
        raise_organizer_error(Organizer::DSLException, :invalid_organizer_name))
    end
  end

  describe "#collection" do
    it "executes add_collection class method on generated MyOrganizer class" do
      valid_collection = [{ attr1: "value1" }, { attr1: "value2" }]
      dsl.collection { valid_collection }
      expect(MyOrganizer.new.collection.count).to eq(2)
    end
  end

  describe "#default_filter" do
    it "executes add_default_filter class method on generated MyOrganizer class" do
      dsl.default_filter {}
      expect(MyOrganizer.filters_manager.send(:default_filters).count).to eq(1)
    end
  end

  describe "#filter" do
    it "executes add_filter class method on generated MyOrganizer class" do
      dsl.filter(:my_filter) {}
      expect(MyOrganizer.filters_manager.send(:normal_filters).count).to eq(1)
    end

    it "executes add_filter (with true accepted value) on generated MyOrganizer class" do
      dsl.filter(:my_filter) {|organizer_item, value|}
      expect(MyOrganizer.filters_manager.send(:filters_with_values).count).to eq(1)
    end
  end

  describe "operation" do
    it "executes operation class method on generated MyOrganizer class" do
      dsl.operation(:my_operation) {}
      expect(MyOrganizer.operations_manager.send(:operations).count).to eq(1)
    end
  end
end
