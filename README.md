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

## Organizer Definition

First, you need to define an organizer like this:

```ruby
Organizer::Template.define("my_organizer") do
  # definition methods
end
```

Inside define's method block, you can pass:

### A Collection

This method takes a block containing a denormalized collection. The block's content will be executed later. So, you can pass anything that produces a collection.

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

```ruby
Organizer::Template.define("my_organizer") do
  collection do
    SampleClass.get_collection
  end
end
```

### A Default Filter

You can add conditions that will be evaluated over each collection's item in order to perform an initial filter of the whole dataset.

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...

  default_filter do |item|
    item.attr1 > 5
  end
end
```

Adding this default filter will reduce the whole dataset to work with `[{ attr1: 6, attr2: "Ciao" }, { attr1: 84, attr2: "Hola" }]` only.

### An Operation

You can perform operations between item's attribute values. The result of this operations will be added, as new attributes, to each collection item with the operation's name. For example:

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...

  operation(:attrs_sum) do |item|
    item.attr1 + item.attr2
  end
end
```

The resulting collection will be something like this:

```ruby
[
  { attr1: 4, attr2: "Hi", attr3: 6, attrs_sum: 10 },
  { attr1: 6, attr2: "Ciao", attr3: 4, attrs_sum: 10 },
  { attr1: 84, attr2: "Hola", attr3: 16, attrs_sum: 100 }
]
```

You also can perform operations using the resulting attributes. For example:

```ruby
Organizer::Template.define("my_organizer") do
  # collection definiton...
  # default filters...

  operation(:attrs_sum) do |item|
    item.attr1 + item.attr2
  end

  operation(:newer_attribute) do |item|
    item.attrs_sum * 2
  end
end
```

The resulting collection will be something like this:

```ruby
[
  { attr1: 4, attr2: "Hi", attr3: 6, attrs_sum: 10, newer_attribute: 20 },
  { attr1: 6, attr2: "Ciao", attr3: 4, attrs_sum: 10, newer_attribute: 20 },
  { attr1: 84, attr2: "Hola", attr3: 16, attrs_sum: 100, newer_attribute: 200 }
]
```

## Usage

After define a new Organizer, you can use it like this:

```ruby
organizer = MyOrganizer.new
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
