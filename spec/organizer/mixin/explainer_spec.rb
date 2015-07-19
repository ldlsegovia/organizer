require 'spec_helper'

describe Organizer::Explainer do
  describe "#explain" do
    before do
      ["SubItem", "Item", "Collection"].each do |class_name|
        Object.send(:remove_const, "Organizer::Test::#{class_name}") rescue nil
      end

      module Organizer
        module Test
          class SubItem
            include Organizer::AttributesHandler
            include Organizer::CollectionItem
            include Organizer::Explainer
          end

          class Item < Array
            include Organizer::AttributesHandler
            include Organizer::CollectionItem
            include Organizer::Collection
            include Organizer::Explainer

            collectable_classes Organizer::Test::SubItem
          end

          class Collection < Array
            include Organizer::Collection
            include Organizer::Explainer

            collectable_classes Organizer::Test::Item
          end
        end
      end
    end

    context "with a dummy class" do
      before do
        Object.send(:remove_const, "Organizer::Test::Dummy") rescue nil

        class Organizer::Test::Dummy
          include Organizer::Explainer
        end
      end

      it "returns class name only" do
        expect { Organizer::Test::Dummy.new.explain(false) }.to output("Test::Dummy\n").to_stdout
      end
    end

    context "with a collection" do
      let!(:collection) { Organizer::Test::Collection.new }

      it "shows empty collection message" do
        out = <<-EOS
Test::Collection
  Empty collection...
EOS
        expect { collection.explain(false) }.to output(out).to_stdout
      end

      it "shows colored output" do
        out = "\e[0;32;49mTest::Collection\e[0m\n  \e[0;92;49mEmpty collection...\e[0m\n"
        expect { collection.explain }.to output(out).to_stdout
      end

      context "with items" do
        before { 3.times.each { collection << Organizer::Test::Item.new } }

        it "shows collection items" do
          out = <<-EOS
Test::Collection
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
EOS
          expect { collection.explain(false) }.to output(out).to_stdout
        end

        context "when collection item names are defined" do
          before do
            collection.each_with_index do |item, idx|
              item.instance_variable_set(:@item_name, "item#{idx}")
            end
          end

          it "shows collection item names" do
            out = <<-EOS
Test::Collection
  Test::Item | item0
    Empty collection...
  Test::Item | item1
    Empty collection...
  Test::Item | item2
    Empty collection...
EOS
            expect { collection.explain(false) }.to output(out).to_stdout
          end
        end

        context "with to many items" do
          before { 17.times.each { collection << Organizer::Test::Item.new } }

          it "shows reduced items list when default limit to show is exceded" do
            out = <<-EOS
Test::Collection
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  and 10 more collection items...
EOS
            expect { collection.explain(false) }.to output(out).to_stdout
          end

          it "shows reduced items list based on _collection_limit argument" do
            out = <<-EOS
Test::Collection
  Test::Item
    Empty collection...
  Test::Item
    Empty collection...
  and 18 more collection items...
EOS
            expect { collection.explain(false, 2) }.to output(out).to_stdout
          end
        end

        context "with sub items" do
          before do
            collection.each do |item|
              2.times.each { item << Organizer::Test::SubItem.new }
            end
          end

          it "shows sub items" do
            out = <<-EOS
Test::Collection
  Test::Item
    Test::SubItem
    Test::SubItem
  Test::Item
    Test::SubItem
    Test::SubItem
  Test::Item
    Test::SubItem
    Test::SubItem
EOS
            expect { collection.explain(false) }.to output(out).to_stdout
          end

          context "with defined attributes" do
            before do
              collection.each do |item|
                item.define_attributes({ site_id: 2, title: "item title" })
                item.each do |sub_item|
                  sub_item.define_attributes({ section_id: 4, title: "sub item title" })
                end
              end
            end

            it "shows items and sub items with defined attributes" do
              out = <<-EOS
Test::Collection
  Test::Item | site_id=2 title="item title"
    Test::SubItem | section_id=4 title="sub item title"
    Test::SubItem | section_id=4 title="sub item title"
  Test::Item | site_id=2 title="item title"
    Test::SubItem | section_id=4 title="sub item title"
    Test::SubItem | section_id=4 title="sub item title"
  Test::Item | site_id=2 title="item title"
    Test::SubItem | section_id=4 title="sub item title"
    Test::SubItem | section_id=4 title="sub item title"
EOS
              expect { collection.explain(false) }.to output(out).to_stdout
            end

            context "with attributes and collection item names" do
              before do
                collection.each_with_index do |item, index|
                  item.instance_variable_set(:@item_name, "item#{index}")
                  item.each_with_index do |sub_item, idx|
                    sub_item.instance_variable_set(:@item_name, "sub_item#{idx}")
                  end
                end
              end

              it "shows items and sub items with defined attributes and name" do
                out = <<-EOS
Test::Collection
  Test::Item | item0 | site_id=2 title="item title"
    Test::SubItem | sub_item0 | section_id=4 title="sub item title"
    Test::SubItem | sub_item1 | section_id=4 title="sub item title"
  Test::Item | item1 | site_id=2 title="item title"
    Test::SubItem | sub_item0 | section_id=4 title="sub item title"
    Test::SubItem | sub_item1 | section_id=4 title="sub item title"
  Test::Item | item2 | site_id=2 title="item title"
    Test::SubItem | sub_item0 | section_id=4 title="sub item title"
    Test::SubItem | sub_item1 | section_id=4 title="sub item title"
EOS
                expect { collection.explain(false) }.to output(out).to_stdout
              end
            end
          end
        end
      end
    end
  end
end
