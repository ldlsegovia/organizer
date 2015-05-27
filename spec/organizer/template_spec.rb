require 'spec_helper'

describe Organizer::Template do
  describe "#define" do
    before do
      Object.send(:remove_const, :MyOrganizer) rescue nil
    end

    it "creates a MyOrganizer class" do
      subject.define("my_organizer") {}
      expect(Object.const_defined?("MyOrganizer")).to be_truthy
      expect(MyOrganizer.superclass).to be(Organizer::Base)
    end

    it "raises error with invalid organizer name" do
      expect { subject.define("invalid*class<name") }.to(
        raise_organizer_error(Organizer::TemplateException, :invalid_organizer_name))
    end

    it "raises error with nil organizer name" do
      expect { subject.define(nil) }.to(
        raise_organizer_error(Organizer::TemplateException, :invalid_organizer_name))
    end

    describe "collection method" do
      it "creates the collection instance method on the generated MyOrganizer class" do
        valid_collection = [{ attr1: "value1" }, { attr1: "value2" }]
        subject.define("my_organizer") { collection { valid_collection } }
        expect(MyOrganizer.new.collection.count).to eq(2)
      end
    end

    describe "default_filter method" do
      it "executes default_filter class method on generated MyOrganizer class" do
        subject.define("my_organizer") { default_filter {} }
        expect(MyOrganizer.filters_manager.send(:default_filters).count).to eq(1)
      end
    end

    describe "filter method" do
      it "executes filter class method on generated MyOrganizer class" do
        subject.define("my_organizer") { filter(:my_filter) {} }
        expect(MyOrganizer.filters_manager.send(:normal_filters).count).to eq(1)
      end
    end

    describe "operation method" do
      it "executes operation class method on generated MyOrganizer class" do
        subject.define("my_organizer") { operation(:my_operation) {} }
        expect(MyOrganizer.operations.count).to eq(1)
      end
    end
  end
end
