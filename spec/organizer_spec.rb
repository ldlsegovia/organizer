require 'spec_helper'

describe Organizer do
  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "#define" do
    before { Object.send(:remove_const, :MyOrganizer) rescue nil }

    it "creates a MyOrganizer class" do
      expect { MyOrganizer }.to raise_error(NameError)
      Organizer.define("my_organizer") {}
      expect(MyOrganizer.superclass).to be(Organizer::Base)
    end

    it "raises error with invalid organizer name" do
      ["invalid*class<name", nil].each do |class_name|
        expect { Organizer.define(class_name) }.to(
          raise_organizer_error(Organizer::DSLException, :invalid_organizer_name))
      end
    end

    it "raises error passing invalid dsl methods in definition block" do
      {
        group: :my_group
      }.each do |dsl_method, params|
        Object.send(:remove_const, :MyOrganizer) rescue nil
        expect do
          Organizer.define("my_organizer") do
            if params
              send(dsl_method, params)
            else
              send(dsl_method)
            end
          end
        end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
      end
    end

    describe "#collection" do
      let_collection(:collection)

      context "with unfiltered collection" do
        before do
          valid_collection = raw_collection

          Organizer.define("my_organizer") do
            collection { valid_collection }
          end

          @collection = MyOrganizer.new.collection
        end

        it "adds a collection to MyOrganizer class" do
          expect(@collection.count).to eq(9)
          expect(@collection).to be_a(Organizer::Source::Collection)
        end

        context "working with another organizer" do
          before do
            Object.send(:remove_const, :AnotherOrganizer) rescue nil
            another_collection = [
              { worker_id: 1, last_name: "Segovia" },
              { workder_id: 2, last_name: "Longone" }
            ]

            Organizer.define("another_organizer") do
              collection { another_collection }
            end

            @collection2 = AnotherOrganizer.new.collection
          end

          it "keeps collections on each class" do
            expect(@collection.size).to eq(9)
            expect(@collection2.size).to eq(2)
          end
        end
      end

      context "with filtered collection" do
        before do
          valid_collection = raw_collection

          Organizer.define("my_organizer") do
            collection do |options|
              valid_collection.select { |item| item[:age] < options[:age] }
            end
          end

          @collection = MyOrganizer.new(age: 9).collection
        end

        it "uses filters passed on initialize" do
          expect(@collection.count).to eq(1)
          expect(@collection).to be_a(Organizer::Source::Collection)
        end
      end
    end

    describe "#default_filter" do
      before do
        Organizer.define("my_organizer") { default_filter {} }
        @filters = MyOrganizer.filters_manager.send(:default_filters)
      end

      it "adds a default filter to MyOrganizer class" do
        expect(@filters.count).to eq(1)
        expect(@filters.first).to be_a(Organizer::Filter::Item)
      end
    end

    describe "#filter" do
      context "with normal filters" do
        before do
          Organizer.define("my_organizer") do
            filter(:my_filter) {}
          end

          @filters = MyOrganizer.filters_manager.send(:normal_filters)
        end

        it "adds a filter to MyOrganizer class" do
          expect(@filters.count).to eq(1)
          expect(@filters.first).to be_a(Organizer::Filter::Item)
        end
      end

      context "with filters accepting params" do
        before do
          Organizer.define("my_organizer") do
            filter(:my_filter) { |organizer_item, value| }
          end

          @filters = MyOrganizer.filters_manager.send(:filters_with_values)
        end

        it "adds a filter to MyOrganizer class" do
          expect(@filters.count).to eq(1)
          expect(@filters.first).to be_a(Organizer::Filter::Item)
        end
      end
    end

    describe "#operation" do
      context "in root context" do
        before do
          Organizer.define("my_organizer") { operation(:my_operation) {} }
          @operations = MyOrganizer.operations
        end

        it "adds an operation to MyOrganizer class" do
          expect(@operations.count).to eq(1)
          expect(@operations).to be_a(Organizer::Operation::Collection)
        end
      end

      context "in groups context" do
        before do
          Organizer.define("my_organizer") do
            groups do
              operation(:operation_1, 10) {}
              operation(:operation_2) {}
            end
          end

          @operations = MyOrganizer.group_operations
          @operation1 = @operations.first
          @operation2 = @operations.last
        end

        it "adds group operations to MyOrganizer class" do
          expect(@operations.count).to eq(2)
          expect(@operations).to be_a(Organizer::Operation::Collection)
        end

        it "adds operation 1 to group" do
          expect(@operation1.item_name).to eq(:operation_1)
          expect(@operation1.initial_value).to eq(10)
        end

        it "adds operation 2 to group "do
          expect(@operation2.item_name).to eq(:operation_2)
          expect(@operation2.initial_value).to eq(0)
        end
      end
    end

    describe "#groups" do
      it { expect { Organizer.define("my_organizer") { groups {} } }.to_not raise_error }

      it "raises error passing invalid methods in groups definition block" do
        {
          collection: nil,
          filter: :my_filter,
          default_filter: nil,
          groups: nil,
        }.each do |dsl_method, params|
          Object.send(:remove_const, :MyOrganizer) rescue nil
          expect do
            Organizer.define("my_organizer") do
              groups do
                if params
                  send(dsl_method, params)
                else
                  send(dsl_method)
                end
              end
            end
          end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
        end
      end
    end

    describe "#group" do
      context "in groups context" do
        before do
          Organizer.define("my_organizer") do
            groups do
              group(:store_id, :store) {}
            end
          end

          @groups = MyOrganizer.groups
        end

        it "adds a group to MyOrganizer class" do
          expect(@groups.count).to eq(1)
          expect(@groups.first).to be_a(Organizer::Group::Item)
        end
      end

      context "in group context" do
        it "raises error passing invalid methods in group definition block" do
          {
            collection: nil,
            filter: :my_filter,
            default_filter: nil,
            groups: nil,
            operation: :my_operation
          }.each do |dsl_method, params|
            Object.send(:remove_const, :MyOrganizer) rescue nil
            expect do
              Organizer.define("my_organizer") do
                groups do
                  group(:my_group) do
                    if params
                      send(dsl_method, params)
                    else
                      send(dsl_method)
                    end
                  end
                end
              end
            end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
          end
        end

        it "raises error trying to add a two groups at the same definition level" do
          expect do
            Organizer.define("my_organizer") do
              groups do
                group(:g1) do
                  group(:g2)
                  group(:g3)
                end
              end
            end
          end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
        end

        context "with nested groups" do
          before do
            Organizer.define("my_organizer") do
              groups do
                group(:g1) do
                  group(:g2) do
                    group(:g3)
                  end
                end
              end
            end

            @groups = MyOrganizer.groups
          end

          it "adds a group nested to another group" do
            expect(@groups.first.parent_name).to be_nil
            expect(@groups.second.parent_name).to eq(:g1)
            expect(@groups.third.parent_name).to eq(:g2)
          end
        end
      end
    end
  end
end
