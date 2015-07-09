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

  describe "#operation" do
    it "executes operation class method on generated MyOrganizer class" do
      dsl.operation(:my_operation) {}
      expect(MyOrganizer.operations_manager.send(:operations).count).to eq(1)
    end

    it "adds operations nested to group" do
      dsl.group(:store_id) do
        operation(:operation_1, 10) {}
        operation(:operation_2) {}
      end

      operations = MyOrganizer.operations_manager.send(:group_operations)
      expect(operations.count).to eq(2)
      expect(operations.first.name).to eq(:operation_1)
      expect(operations.first.group_name).to eq(:store_id)
      expect(operations.first.initial_value).to eq(10)
      expect(operations.last.name).to eq(:operation_2)
      expect(operations.last.group_name).to eq(:store_id)
      expect(operations.last.initial_value).to eq(0)
    end
  end

  describe "#group" do
    it "executes add_group class method on generated MyOrganizer class" do
      dsl.group(:store_id, :store) {}
      expect(MyOrganizer.groups_manager.send(:groups).count).to eq(1)
    end

    it "raises forbidden nesting passing a collection as definition" do
      expect { dsl.group(:my_group) { collection {} } }.to(
        raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
    end

    it "raises forbidden nesting passing a default filter as definition" do
      expect { dsl.group(:my_group) { default_filter(:filter) {} } }.to(
        raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
    end

    it "raises forbidden nesting passing a filter as definition" do
      expect { dsl.group(:my_group) { filter(:filter) {} } }.to(
        raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
    end

    it "adds a group nested to another group" do
      dsl.group(:g1) do
        group(:g2) {}
      end

      skip
    end

    it "raises error trying to add a two groups at the same definition level" do
      dsl.group(:g1) do
        group(:g2) {}
        group(:g3) {}
      end

      skip
    end
  end
end
