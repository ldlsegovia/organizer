# Organizer

Organizer is a ruby gem that allows you to perform different actions like: filtering, ordering and default or custom operations over denormalized data, in order to produce a new data structure with the result.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "organizer"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install organizer
```

## Organizer Definition and Usage

First, you need to define an organizer like this:

```ruby
Organizer::Template.define("my_organizer") do
  # definition methods
end
```

To use it, you need to do:

```ruby
organizer = MyOrganizer.new
```

Inside define's method block, you can pass:

### A Collection

This method takes a block containing a denormalized collection. The block's content will be executed later. So, you can pass anything that produces a collection.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  collection do
    [
      { attr1: 4, attr2: "Hi", attr3: 6 },
      { attr1: 6, attr2: "Ciao", attr3: 4 },
      { attr1: 84, attr2: "Hola", attr3: 16 }
    ]
  end
end
```

Also, you can pass options (filters usually) to get a desired raw collection: `organizer = MyOrganizer.new({attr1: 84})`.
These options will be present as the first param on collection definition like this:

```ruby
Organizer::Template.define("my_organizer") do
  collection do |collection_options|
    data = [
      { attr1: 4, attr2: "Hi", attr3: 6 },
      { attr1: 6, attr2: "Ciao", attr3: 4 },
      { attr1: 84, attr2: "Hola", attr3: 16 }
    ]

    data.select { |item| item[:attr1] == collection_options[:attr1]}
  end
end
```

#### Usage Example

```ruby
# with defined collection for the first example
MyOrganizer.new.organize
#<Organizer::Item:0x007f8eaac429b8 @attr1=4, @attr2="Hi", @attr3=6>,
#<Organizer::Item:0x007f8eaac423c8 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007f8eaac41478 @attr1=84, @attr2="Hola", @attr3=16>

# with defined collection for the second example (applying the filter)
MyOrganizer.new.organize
#<Organizer::Item:0x007f8eaac41478 @attr1=84, @attr2="Hola", @attr3=16>
```

### A Default Filter

Allows you to define conditions that will be evaluated, over each collection item, at the beginning of the data generation, in order to perform an initial filter of the whole dataset.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...

  default_filter do |item|
    item.attr1 > 5
  end

  default_filter(:named_default_filter) do |item|
    item.attr1 < 200
  end
end
```

#### Usage Example

```ruby
# with default filters
MyOrganizer.new.organize
#<Organizer::Item:0x007fb6aac190e0 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007fb6aac23c20 @attr1=84, @attr2="Hola", @attr3=16>

# skiping all default filters
MyOrganizer.new.organize(skip_default_filters: :all)
#<Organizer::Item:0x007f8eaac429b8 @attr1=4, @attr2="Hi", @attr3=6>,
#<Organizer::Item:0x007f8eaac423c8 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007f8eaac41478 @attr1=84, @attr2="Hola", @attr3=16>

# skiping default filters by name
MyOrganizer.new.organize(skip_default_filters: [:named_default_filter])
#<Organizer::Item:0x007f8eaac429b8 @attr1=4, @attr2="Hi", @attr3=6>,
#<Organizer::Item:0x007f8eaac423c8 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007f8eaac41478 @attr1=84, @attr2="Hola", @attr3=16>
```

### A Filter

Allows you to define conditions that will not be initially evaluated but user may activate later.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...

  filter(:filter1) do |item|
    item.attr1 > 5
  end
end
```
You can define filters that will accept user params like this:

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...

  filter(:filter2, true) do |item, value|
    item.attr1 > value
  end
end
```

#### Usage Example

```ruby
# enabling filters
MyOrganizer.new.organize(enabled_filters: [:filter1])
#<Organizer::Item:0x007fb020ca23d0 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007fb020ca1520 @attr1=84, @attr2="Hola", @attr3=16>

# passing values to filters
MyOrganizer.new.organize(filters: { filter2: 5 })
#<Organizer::Item:0x007fb020ca23d0 @attr1=6, @attr2="Ciao", @attr3=4>,
#<Organizer::Item:0x007fb020ca1520 @attr1=84, @attr2="Hola", @attr3=16>
```

### An Operation

You can perform operations between item's attribute values. The result of this operations will be added, as new attributes, to each collection item with the operation's name. For example:

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...
  # filters...

  operation(:attrs_sum) do |item|
    item.attr1 + item.attr3
  end
end
```

You also can perform operations using the resulting attributes. For example:

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...
  # filters...

  operation(:attrs_sum) do |item|
    item.attr1 + item.attr3
  end

  operation(:newer_attribute) do |item|
    item.attrs_sum * 2
  end
end
```

#### Example Usage

```ruby
# with operations
MyOrganizer.new.organize
#<Organizer::Item:0x007fd49a4bbc90 @attr1=4, @attr2="Hi", @attr3=6, @attrs_sum=10>,
#<Organizer::Item:0x007fd49a4bb3a8 @attr1=6, @attr2="Ciao", @attr3=4, @attrs_sum=10>
#<Organizer::Item:0x007fd49a4baa20 @attr1=84, @attr2="Hola", @attr3=16, @attrs_sum=100>
```

## Docs

We are using [YARD](http://yardoc.org/) in this project.

To generate documentation

```bash
$ yard doc
```

To see documentation on `http://localhost:8808/`

```bash
$ yard server --reload
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/organizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
