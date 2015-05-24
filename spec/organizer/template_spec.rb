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

        subject.define("my_organizer") do
          collection { valid_collection }
        end

        collection = MyOrganizer.new.send(:collection)
        expect(collection).to be_a(Organizer::Collection)
        expect(collection.count).to eq(2)
      end

    end

  end

end
