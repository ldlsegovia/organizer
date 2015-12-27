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
        group: :my_group,
        operation: :my_operation,
        default_filter: nil,
        human: :attr1,
      }.each do |dsl_method, params|
        Object.send(:remove_const, :MyOrganizer) rescue nil
        expect do
          Organizer.define("my_organizer") do
            !!params ? send(dsl_method, params) : send(dsl_method)
          end
        end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
      end
    end

    describe "#collection" do
      it "raises error passing invalid methods in collection block" do
        {
          collection: nil,
          generate_filters_for: [:attr1, :attr2],
          filter: :my_filter,
          groups: nil,
          group: :my_group,
        }.each do |dsl_method, params|
          Object.send(:remove_const, :MyOrganizer) rescue nil
          expect do
            Organizer.define("my_organizer") do
              collection do
                !!params ? send(dsl_method, params) : send(dsl_method)
              end
            end
          end.to(raise_organizer_error(Organizer::DSLException, :forbidden_nesting))
        end
      end
    end

    describe "#source" do
      let_collection(:collection)

      context "with unfiltered collection" do
        before do
          valid_collection = raw_collection

          Organizer.define("my_organizer") do
            collection do
              source { valid_collection }
            end
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
              collection do
                source { another_collection }
              end
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
            collection do
              source do |options|
                valid_collection.select { |item| item[:age] < options[:age] }
              end
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
        Organizer.define("my_organizer") do
          collection do
            default_filter {}
          end
        end

        @filters = MyOrganizer.source_default_filters
      end

      it "adds a default filter to MyOrganizer class" do
        expect(@filters.count).to eq(1)
        expect(@filters.first).to be_a(Organizer::Filter::Item)
      end
    end

    describe "#generate_filters_for" do
      before do
        Organizer.define("my_organizer") do
          generate_filters_for(:attr1, :attr2)
        end

        @filters = MyOrganizer.filters
      end

      it "adds generated filters for attrs" do
        expect(@filters.size).to eq(18)
      end
    end

    describe "#filter" do
      context "with normal filters" do
        before do
          Organizer.define("my_organizer") do
            filter(:my_filter) {}
          end

          @filters = MyOrganizer.filters
        end

        it "adds a filter to MyOrganizer class" do
          expect(@filters.count).to eq(1)
          expect(@filters.first).to be_a(Organizer::Filter::Item)
        end
      end
    end

    describe "#human" do
      before do
        Organizer.define("my_organizer") do
          collection do
            human(:amount, :currency, unit: "€", precision: 3)
          end
        end

        @operations = MyOrganizer.source_operations
      end

      it "adds mask operation" do
        expect(@operations.count).to eq(1)
        expect(@operations).to be_a(Organizer::Operation::Collection)
      end
    end

    describe "#operation" do
      context "in collection context" do
        before do
          Organizer.define("my_organizer") do
            collection do
              operation(:my_operation) {}
            end
          end

          @operations = MyOrganizer.source_operations
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
              parent_operation(:operation_1, 10) {}
              parent_operation(:operation_2) {}

              group(:gender) do
                parent_operation(:operation_3, 20) {}
                parent_operation(:operation_4) {}
              end

              group(:site) do
                parent_operation(:operation_5) {}
              end
            end
          end

          @global_operations = MyOrganizer.groups_parent_item_operations
          @global_operation1 = @global_operations.first
          @global_operation2 = @global_operations.last

          @gender_operations = MyOrganizer.groups[:gender].parent_item_operations(:gender)
          @site_operations = MyOrganizer.groups[:site].parent_item_operations(:site)
        end

        it "adds groups operations to MyOrganizer class" do
          expect(@global_operations.count).to eq(2)
          expect(@global_operations).to be_a(Organizer::Operation::Collection)
        end

        it "keeps global operations" do
          expect(@global_operation1.item_name).to eq(:operation_1)
          expect(@global_operation1.initial_value).to eq(10)
          expect(@global_operation2.item_name).to eq(:operation_2)
          expect(@global_operation2.initial_value).to eq(0)
        end

        it "keeps specific group operations" do
          expect(@gender_operations.count).to eq(2)
          expect(@site_operations.count).to eq(1)
          expect(@gender_operations.first.item_name).to eq(:operation_3)
          expect(@gender_operations.first.initial_value).to eq(20)
          expect(@gender_operations.last.item_name).to eq(:operation_4)
          expect(@site_operations.first.item_name).to eq(:operation_5)
        end
      end
    end

    describe "#groups" do
      it { expect { Organizer.define("my_organizer") { groups {} } }.to_not raise_error }

      it "raises error passing invalid methods in groups definition block" do
        {
          collection: nil,
          source: nil,
          filter: :my_filter,
          default_filter: nil,
          groups: nil,
          generate_filters_for: [:attr1, :attr2],
          human: :attr1,
        }.each do |dsl_method, params|
          Object.send(:remove_const, :MyOrganizer) rescue nil
          expect do
            Organizer.define("my_organizer") do
              groups do
                !!params ? send(dsl_method, params) : send(dsl_method)
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
              group(:store, :store_id) {}
            end
          end

          @groups = MyOrganizer.groups
        end

        it "adds a group to MyOrganizer class" do
          expect(@groups.keys.count).to eq(1)
          expect(@groups[:store]).to be_a(Organizer::Group::DefinitionsCollection)
          expect(@groups[:store].first.item_name).to eq(:store)
        end
      end

      context "in group context" do
        it "raises error passing invalid methods in group definition block" do
          {
            collection: nil,
            source: nil,
            filter: :my_filter,
            default_filter: nil,
            generate_filters_for: [:attr1, :attr2],
            groups: nil,
            human: :attr1,
          }.each do |dsl_method, params|
            Object.send(:remove_const, :MyOrganizer) rescue nil
            expect do
              Organizer.define("my_organizer") do
                groups do
                  group(:my_group) do
                    !!params ? send(dsl_method, params) : send(dsl_method)
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

        it "raises error trying to add two parent groups with same name" do
          expect do
            Organizer.define("my_organizer") do
              groups do
                group(:g1)
                group(:g1)
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

            @groups = MyOrganizer.groups[:g1]
          end

          it "adds nested groups in order" do
            expect(@groups.first.item_name).to eq(:g1)
            expect(@groups.second.item_name).to eq(:g2)
            expect(@groups.third.item_name).to eq(:g3)
          end
        end
      end
    end
  end
end
