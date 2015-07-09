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
      { age: 22, name: "Juan Manuel", site_id: 1, store_id: 1, gender: "M", savings: 20.50 },
      { age: 31, name: "Leandro", site_id: 1, store_id: 1, gender: "M", savings: 15.50 },
      { age: 64, name: "Susana", site_id: 2, store_id: 2, gender: "F", savings: 30.00 },
      { age: 65, name: "Rodolfo", site_id: 2, store_id: 2, gender: "M", savings: 50.20 },
      { age: 33, name: "Virginia", site_id: 2, store_id: 3, gender: "F", savings: 70.10 },
      { age: 8, name: "Francisco", site_id: 2, store_id: 3, gender: "M", savings: 2.50 },
      { age: 31, name: "Gustavo", site_id: 3, store_id: 4, gender: "M", savings: 40.50 },
      { age: 33, name: "Gabriela", site_id: 3, store_id: 4, gender: "F", savings: 45.50 },
      { age: 35, name: "Javier", site_id: 3, store_id: 5, gender: "M", savings: 25.50 }
    ]
  end
end
```

Also, you can pass options (filters usually) to get a desired raw collection: `organizer = MyOrganizer.new({ age: 33 })`.
These options will be present as the first param on collection definition like this:

```ruby
Organizer::Template.define("my_organizer") do
  collection do |collection_options|
    data = [
      { age: 22, name: "Juan Manuel", site_id: 1, store_id: 1, gender: "M", savings: 20.50 },
      { age: 31, name: "Leandro", site_id: 1, store_id: 1, gender: "M", savings: 15.50 },
      { age: 64, name: "Susana", site_id: 2, store_id: 2, gender: "F", savings: 30.00 },
      { age: 65, name: "Rodolfo", site_id: 2, store_id: 2, gender: "M", savings: 50.20 },
      { age: 33, name: "Virginia", site_id: 2, store_id: 3, gender: "F", savings: 70.10 },
      { age: 8, name: "Francisco", site_id: 2, store_id: 3, gender: "M", savings: 2.50 },
      { age: 31, name: "Gustavo", site_id: 3, store_id: 4, gender: "M", savings: 40.50 },
      { age: 33, name: "Gabriela", site_id: 3, store_id: 4, gender: "F", savings: 45.50 },
      { age: 35, name: "Javier", site_id: 3, store_id: 5, gender: "M", savings: 25.50 }
    ]

    data.select { |item| item[:age] == collection_options[:age]}
  end
end
```

#### Usage Example

```ruby
# with defined collection for the first example
MyOrganizer.new.organize
#<Organizer::Item:0x007fa9646e3290 @age=22, @name="Juan Manuel", @site_id=1, @store_id=1, @gender="M", @savings=20.5>
#<Organizer::Item:0x007fa9646e23b8 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5>
#<Organizer::Item:0x007fa9646e1620 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0>
#<Organizer::Item:0x007fa9646e0888 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2>
#<Organizer::Item:0x007fa964518398 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1>
#<Organizer::Item:0x007fa9646f3320 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5>
#<Organizer::Item:0x007fa9646f2588 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5>
#<Organizer::Item:0x007fa9646f17f0 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5>
#<Organizer::Item:0x007fa9646f0a58 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>

# with defined collection for the second example (applying the filter)
MyOrganizer.new(age: 8).organize
#<Organizer::Item:0x007ffd83f7b178 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5>
```

### A Default Filter

Allows you to define conditions that will be evaluated, over each collection item, at the beginning of the data generation, in order to perform an initial filter of the whole dataset.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection and other definitions...

  default_filter do |item|
    item.age > 22
  end

  default_filter(:named_default_filter) do |item|
    item.age < 60
  end
end
```

#### Usage Example

```ruby
# with default filters
MyOrganizer.new.organize
#<Organizer::Item:0x007fec1cd6e650 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5>
#<Organizer::Item:0x007fec1cd76d78 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1>
#<Organizer::Item:0x007fec1cd85878 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5>
#<Organizer::Item:0x007fec1cd8ece8 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5>
#<Organizer::Item:0x007fec1cd8d168 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>

# skiping all default filters
MyOrganizer.new.organize(skip_default_filters: :all)
#<Organizer::Item:0x007fb60b526fe8 @age=22, @name="Juan Manuel", @site_id=1, @store_id=1, @gender="M", @savings=20.5>
#<Organizer::Item:0x007fb60b526110 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5>
#<Organizer::Item:0x007fb60b525378 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0>
#<Organizer::Item:0x007fb60b5245e0 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2>
#<Organizer::Item:0x007fb60b52fdc8 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1>
#<Organizer::Item:0x007fb60b52f030 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5>
#<Organizer::Item:0x007fb60b52e298 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5>
#<Organizer::Item:0x007fb60b52d500 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5>
#<Organizer::Item:0x007fb60b52c768 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>

# skiping default filters by name
MyOrganizer.new.organize(skip_default_filters: [:named_default_filter])
#<Organizer::Item:0x007f9b62a40df8 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5>
#<Organizer::Item:0x007f9b62a42568 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0>
#<Organizer::Item:0x007f9b62a40e20 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2>
#<Organizer::Item:0x007f9b62a4b438 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1>
#<Organizer::Item:0x007f9b62a59ee8 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5>
#<Organizer::Item:0x007f9b62a62db8 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5>
#<Organizer::Item:0x007f9b62a61120 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>

```

### A Filter

Allows you to define conditions that will not be initially evaluated but user may activate later.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection and other definitions...

  filter(:filter1) do |item|
    item.age > 33
  end
end
```
You can define filters that will accept user params, declaring a second block argument.

```ruby
Organizer::Template.define("my_organizer") do
  # collection and other definitions...

  filter(:filter2) do |item, value|
    item.age == value
  end
end
```

#### Usage Example

```ruby
# enabling filters
MyOrganizer.new.organize(enabled_filters: [:filter1])
#<Organizer::Item:0x007fd7952e9338 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0>
#<Organizer::Item:0x007fd7952e85a0 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2>
#<Organizer::Item:0x007fd7952f4738 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>

# passing values to filters
MyOrganizer.new.organize(filters: { filter2: 5 })
#<Organizer::Item:0x007fa621ea6f40 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5>
```

### An Operation

You can perform operations between item's attribute values. The result of this operations will be added, as new attributes, to each collection item with the operation's name. For example:

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
  # collection and other definitions...

  operation(:attrs_sum) do |item|
    item.age * 2
  end
end
```

You also can perform operations using the resulting attributes. For example:

```ruby
Organizer::Template.define("my_organizer") do
  # collection and other definitions...

  operation(:newer_attribute) do |item|
    item.attrs_sum * 2
  end
end
```

#### Usage Example

```ruby
# with operations
MyOrganizer.new.organize
#<Organizer::Item:0x007fef3b3a2eb0 @age=22, @name="Juan Manuel", @site_id=1, @store_id=1, @gender="M", @savings=20.5, @attrs_sum=44, @newer_attribute=88>
#<Organizer::Item:0x007fef3b3a1fd8 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5, @attrs_sum=62, @newer_attribute=124>
#<Organizer::Item:0x007fef3b3a1240 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0, @attrs_sum=128, @newer_attribute=256>
#<Organizer::Item:0x007fef3b3a04a8 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2, @attrs_sum=130, @newer_attribute=260>
#<Organizer::Item:0x007fef3b3abc40 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1, @attrs_sum=66, @newer_attribute=132>
#<Organizer::Item:0x007fef3b3aaea8 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5, @attrs_sum=16, @newer_attribute=32>
#<Organizer::Item:0x007fef3b3aa110 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5, @attrs_sum=62, @newer_attribute=124>
#<Organizer::Item:0x007fef3b3a9378 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5, @attrs_sum=66, @newer_attribute=132>
#<Organizer::Item:0x007fef3b3a85e0 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5, @attrs_sum=70, @newer_attribute=140>
```

### A Group

You can define groups. The data will be grouped by the attribute passed in params.

#### Definition Example

```ruby
Organizer::Template.define("my_organizer") do
 # collection and other definitions...

  group(:site_id)
end
```

You can define operations for a given group.

```ruby
Organizer::Template.define("my_organizer") do
 # collection and other definitions...

  group(:site_id) do
    operation(:age_sum) do |group_item, item|
      group_item.age_sum += item.age
    end
  end
end
```

#### Usage Example

Normal example...

```ruby
MyOrganizer.new.organize(group_by: :site_id)
# [
#   [0] [
#       [0] #<Organizer::Item:0x007f93bd304780 @age=22, @name="Juan Manuel", @site_id=1, @store_id=1, @gender="M", @savings=20.5>,
#       [1] #<Organizer::Item:0x007f93bd30f770 @age=31, @name="Leandro", @site_id=1, @store_id=1, @gender="M", @savings=15.5>
#   ],
#   [1] [
#       [0] #<Organizer::Item:0x007f93bd30e820 @age=64, @name="Susana", @site_id=2, @store_id=2, @gender="F", @savings=30.0>,
#       [1] #<Organizer::Item:0x007f93bd30da38 @age=65, @name="Rodolfo", @site_id=2, @store_id=2, @gender="M", @savings=50.2>,
#       [2] #<Organizer::Item:0x007f93bd30ca20 @age=33, @name="Virginia", @site_id=2, @store_id=3, @gender="F", @savings=70.1>,
#       [3] #<Organizer::Item:0x007f93bd3176c8 @age=8, @name="Francisco", @site_id=2, @store_id=3, @gender="M", @savings=2.5>
#   ],
#   [2] [
#       [0] #<Organizer::Item:0x007f93bd316610 @age=31, @name="Gustavo", @site_id=3, @store_id=4, @gender="M", @savings=40.5>,
#       [1] #<Organizer::Item:0x007f93bd3155f8 @age=33, @name="Gabriela", @site_id=3, @store_id=4, @gender="F", @savings=45.5>,
#       [2] #<Organizer::Item:0x007f93bd314540 @age=35, @name="Javier", @site_id=3, @store_id=5, @gender="M", @savings=25.5>
#   ]
# ]
```

Using group operations...

```ruby
MyOrganizer.new.organize(group_by: :site_id).each do |group_item|
  p group_item.age_sum
end

# 53 (22+31)
# 170 (64+65+33+8)
# 99 (31+33+35)

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
