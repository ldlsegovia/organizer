# Organizer

Organizer is a ruby gem that allows you to perform different actions like: filtering, ordering, grouping and operations over denormalized data, in order to produce a new data structure with the result.

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
Organizer.define("my_organizer") do
  # definition methods
end
```

To use it, you need to do:

```ruby
MyOrganizer.new.organize
```

Inside define's method block, you can pass:

### On Root context

#### A Collection

This method takes a block containing a denormalized collection. The block's content will be executed later. So, you can pass anything that produces a collection.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
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
Organizer.define("my_organizer") do
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

##### Usage Example

```ruby
# with defined collection for the first example
MyOrganizer.new.organize

# with defined collection for the second example (applying the filter)
MyOrganizer.new(age: 8).organize
```

#### Default Filters

Allows you to define conditions that will be evaluated, over each collection item, at the beginning of the data generation, in order to perform an initial filter of the whole dataset.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  # root level definitions...

  default_filter do |item|
    item.age > 22
  end

  default_filter(:named_default_filter) do |item|
    item.age < 60
  end
end
```

##### Usage Example

```ruby
# with default filters
MyOrganizer.new.organize

# skiping all default filters
MyOrganizer.new.organize(skip_default_filters: :all)

# skiping default filters by name
MyOrganizer.new.organize(skip_default_filters: [:named_default_filter])
```

#### Filters

Allows you to define conditions that will not be initially evaluated but user may activate later.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  # root level definitions...

  filter(:filter1) do |item|
    item.age > 33
  end
end
```
You can define filters that will accept user params, declaring a second block argument.

```ruby
Organizer.define("my_organizer") do
  # root level definitions...

  filter(:filter2) do |item, value|
    item.age == value
  end
end
```

##### Usage Example

```ruby
# enabling filters
MyOrganizer.new.organize(filters: [:filter1])

# passing values to filters
MyOrganizer.new.organize(filters: { filter2: 5 })
```

#### Operations

You can perform operations between item's attribute values. The result of this operations will be added, as new attributes, to each collection item with the operation's name. For example:

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  # root level definitions...

  operation(:attrs_sum) do |item|
    item.age * 2
  end
end
```

You also can perform operations using the resulting attributes. For example:

```ruby
Organizer.define("my_organizer") do
  # root level definitions...

  operation(:newer_attribute) do |item|
    item.attrs_sum * 2
  end
end
```

##### Usage Example

```ruby
# with operations
MyOrganizer.new.organize
```

### On Groups context

#### Groups

You can define groups. The data will be grouped by the attribute passed in `group_by` param.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
 # root level definitions...

  groups do
    group(my_group: :site_id) # named group
    group(:site_id) # grouping by attribute
    group(:age_greater_than_33, "item.age > 33") # grouping by condition
  end
end
```

##### Usage Example

```ruby
MyOrganizer.new.organize(group_by: :my_group)
MyOrganizer.new.organize(group_by: :site_id)
MyOrganizer.new.organize(group_by: :age_greater_than_33)
```

#### Operations

You can define operations that will be applied to groups only.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
 # root level definitions...

  groups do
    operation(:age_sum) do |group_item, item|
      group_item.age_sum += item.age
    end

    operation(:age_sum_with_initial_value, 10) do |group_item, item|
      group_item.age_sum_with_initial_value += item.age
    end

    group(:site_id)
  end
end
```

##### Usage Example

```ruby
MyOrganizer.new.organize(group_by: :site_id)
```

#### Nested Groups on Definition

You can define nested groups.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
 # root level definitions...

  groups do
    group(:gender) do
      group(:site_id) do
        group(:section_id)
      end
    end
  end
end
```

##### Usage Example

```ruby
MyOrganizer.new.organize(group_by: :gender)
```

#### Nested Groups at Runtime

You can nest groups calling `organize` method passing group names as array param.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
 # root level definitions...

  groups do
    group(:gender)
    group(:site_id)
    group(:section_id)
  end
end
```

##### Usage Example

```ruby
MyOrganizer.new.organize(group_by: [:gender, :site_id, :section_id])
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
