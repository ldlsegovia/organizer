# Organizer

Organizer is a ruby gem that allows you to build, through a DSL, definitions that later will be used, over denormalized data, to perform operations like: **filtering, ordering, grouping, complex attributes generation, etc** easily.

> Keep in mind, this gem is designed to facilitate data structures generation more than performance.

**Table of Contents**

- [Installation](#installation)
- [Definition](#definition)
- [Usage](#usage)
- [Contexts](#contexts)
  - [Collection context](#collection-context)
    - [Source](#source)
    - [Operation](#operation)
    - [Human Attribute](#human-attribute)
    - [Default Filter](#default-filter)
  - [Groups context](#groups-context)
    - [Group](#group)
    - [Group Operation](#group-operation)
    - [Nested Groups](#nested-groups)
  - [Root context](#root-context)
    - [Filter](#filter)
    - [Sort](#sort)
    - [Limit](#limit)
  - [Putting all together](#putting-all-together)

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

## Definition

First, you need to define an organizer. Inside `define` block, you can have two contexts:
* `collection`: inside this block you can add definitions that will be applied to the data source.
* `groups`: inside this block you can add definitions that will be applied to groups only.

```ruby
Organizer.define("my_organizer") do
  # This is the root context. Methods executed here will be applied to both: collection and groups.

  collection do
    # methods executed here will be applied to the collection.
  end

  groups do
    # methods executed here will be applied to groups.
  end
end
```

## Usage

To use it, you need to do:

```ruby
MyOrganizer.new.organize
```

## Contexts

### Collection context

#### Source

This method takes a block containing a denormalized collection. The block's content will be executed later. So, you can pass anything that produces a collection. More specifically, you can pass anything that implements the `each` method.
Each item inside collection must respond to `to_h` method. This gem implements `to_h` on `ActiveRecord::Base` class. So, you can work with Active Record models without to do nothing special.

> Remember: this is the only mandatory method. All actions will be executed over the collection passed here.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  collection do
    source do
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
end
```

Also, you can pass options (filters usually) to get a desired raw collection: `organizer = MyOrganizer.new({ age: 33 })`.
These options will be present as the first param on collection definition like this:

```ruby
Organizer.define("my_organizer") do
  collection do
    source do |collection_options|
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
end
```

##### Usage Example

```ruby
# with defined collection for the first example
MyOrganizer.new.organize

# with defined collection for the second example (applying the filter)
MyOrganizer.new(age: 8).organize
```

#### Operation

You can perform operations between item's attribute values. The result of this operations will be added, as new attributes, to each collection item with the operation's name. For example:

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  collection do
    operation(:attrs_sum) do |item|
      item.age * 2
    end
  end
end
```

You also can perform operations using the resulting attributes. For example:

```ruby
Organizer.define("my_organizer") do
  collection do
    operation(:newer_attribute) do |item|
      item.attrs_sum * 2
    end
  end
end
```

You can mask your operations too. For example:

```ruby
Organizer.define("my_organizer") do
  collection do
    operation(:newer_attribute, currency: { unit: "€" }) do |item|
      item.attrs_sum * 2
    end
  end
end
```

##### Usage Example

```ruby
# You don't need nothing special to apply operations. It's enough with the definition
MyOrganizer.new.organize
```

#### Human Attribute

You can apply a custom format to your attributes.
The available masks are:

* `currency`
* `natural`
* `size`
* `percentage`
* `phone`
* `delimited`
* `rounded`
* `clean`
* `truncated`
* `capitalized`
* `downcase`
* `upcase`
* `date`
* `datetime`
* `time`

> Most are a wrapper of: `http://guides.rubyonrails.org/active_support_core_extensions.html#formatting` Check this out to see mask options.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  collection do
    human(:amount, :currency, unit: "€", precision: 3)
  end
end
```

##### Usage Example

```ruby
# You don't need nothing special to apply a custom format. It's enough with the definition
MyOrganizer.new.organize
```

#### Default Filter

Allows you to define conditions that will be evaluated, over each collection item, at the beginning of the data generation, in order to perform an initial filter of the whole dataset.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  collection do
    default_filter do |item|
      item.age > 22
    end

    default_filter(:filter1) do |item|
      item.age < 60
    end

    default_filter(:filter2) do |item|
      item.age > 10
    end
  end
end
```

##### Usage Example

```ruby
# You don't need nothing special to apply default filters. It's enough with the definition.
MyOrganizer.new.organize

# skipping all default filters
MyOrganizer.new.skip_default_filters(:all).organize

# skipping default filters using filter name
MyOrganizer.new.skip_default_filters(:filter1, :filter2).organize
```

> Remember: skip_default_filters can't be chained like other methods (filter_by, sort_by), it needs to be called first.

### Groups context

#### Group

You can define groups. The data will be grouped by the attribute passed in `group_by` method.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  groups do
    group(:site_id) # grouping by attribute
    group(site: :site_id) # named group
  end
end
```

##### Usage Example

```ruby
MyOrganizer.new.group_by_site.organize

MyOrganizer.new.group_by_site_id.organize
```

#### Group Operation

You can define 3 types of operations:

1. **Parent Operation**: the resulting attribute of this kind of operations is attached to parent group items and calculated based on child group item attributes. A child item can be an `Organizer::Group::Item` instance or `Organizer::Source::Item` on the deepest level of the group hierarchy.
2. **Operation**: this operations are calculated on `Organizer::Group::Item` instances only, using another attributes from the same instance.
3. **Child Operation**: the resulting attribute of this kind of operations is attached to a child item and calculated using parent item attributes. Parent items will always be `Organizer::Group::Item` instances but, child items can be `Organizer::Group::Item`s or `Organizer::Source::Item`s on the deepest level.

Operations defined under `groups` method, will be applied to all groups. However, operations defined under `group` methods will affect that group only.

> Remember: a `child_operation` can't be applied inside `groups` context. It's mandatory to use this kind of operations inside a single `group`.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  groups do
    parent_operation(:age_sum) do |parent_item, item|
      parent_item.age_sum += item.age
    end

    parent_operation(:age_sum_with_initial_value, 10, currency: { unit: "$" }) do |parent_item, item|
      parent_item.age_sum_with_initial_value += item.age
    end

    operation(:double_age_sum) do |item|
      item.age_sum * 2
    end

    group(:gender) do
      parent_operation(:odd_age_count) do |parent_item, item|
        item.age.odd? ? parent_item.odd_age_count + 1 : parent_item.odd_age_count
      end

      operation(:super_double_age_sum, :percentage) do |item|
        item.double_age_sum * 2
      end

      child_operation(:age_salad, :percentage) do |item, gender|
        item.age + gender.super_double_age_sum
      end
    end

    group(:site_id)
  end
end
```

##### Usage Example

```ruby
## You don't need nothing special to apply operations. It's enough with the definition
MyOrganizer.new.group_by_gender.organize
```

#### Nested Groups

You can define nested groups.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
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
# this will group the collection by gender, then each gender by site and then each site by section.
MyOrganizer.new.group_by_gender.organize
```

### Root context

#### Filter

Allows you to define conditions that will be applied to the source collection or group.

##### Definition Example

```ruby
Organizer.define("my_organizer") do
  filter(:filter1) do |item|
    item.age > 33
  end
end
```

You can define filters that will accept user params, declaring a second block argument.

```ruby
Organizer.define("my_organizer") do
  filter(:filter2) do |item, value|
    item.age == value
  end
end
```

Also, you can generate common filters for certain attributes...

```ruby
Organizer.define("my_organizer") do
  generate_filters_for(:name, :savings, :age)
end
```

##### Collection Usage Example

```ruby
# enabling filters
MyOrganizer.new.filter_by(:filter1).organize

# passing values to filters
MyOrganizer.new.filter_by(filter2: 5).organize

# using auto generated common filters
MyOrganizer.new.filter_by(name_contains: "Juan").organize
MyOrganizer.new.filter_by(age_eq: 8).organize
MyOrganizer.new.filter_by(savings_goet: 20).organize

# passing multiple filters
MyOrganizer.new.filter_by(:filter1, filter2: 5).organize
MyOrganizer.new.filter_by(:filter1).filter_by(filter2: 5).organize
```

> Remember: filters will work with generated attributes (operation) too.

##### Group Usage Example

```ruby
# filters 1 and 2 will be applied to :gender group
MyOrganizer.new.group_by_gender.filter_gender_by(:filter1, :filter2)

# filter1 will be applied to :gender group and :filter2 to :site_id group
MyOrganizer.new.group_by_gender.filter_gender_by(:filter1).filter_site_id_by(:filter2).organize
```

> Remember: group filters **can be applied on attributes generated by group operations only**.

#### Sort

Allows you to sort the source collection or groups by one or more attributes in ascending or descending order.

##### Definition Example

It does not need definition.

##### Collection Usage Example

```ruby
# ascending by default
MyOrganizer.new.sort_by(:age).organize

# passing explicit orientation
MyOrganizer.new.sort_by(age: :asc).organize

# descending
MyOrganizer.new.sort_by(age: :desc).organize

# by multiple attributes
MyOrganizer.new.sort_by(age: :desc, :first_name).organize

MyOrganizer.new.sort_by(age: :desc).sort_by(:first_name).organize
```

> Remember: sort by will work with generated attributes (operation) too.

##### Group Usage Example

```ruby
# sort will be applied to :gender group.
MyOrganizer.new.group_by_gender.sort_gender_by(:age).organize

# :age sorting will be applied to :gender group and :first_name to :site_id child group
MyOrganizer.new.group_by_gender.sort_gender_by(age: :desc).sort_site_id_by(:first_name).organize
```

> Remember: sort by **can be applied on attributes generated by group operations only**.

#### Limit

Allows you to cut the source collection or group items.

##### Definition Example

It does not need definition.

##### Collection Usage Example

```ruby
MyOrganizer.new.limit(2).organize
```

##### Group Usage Example

```ruby
# limit will be applied to :gender group.
MyOrganizer.new.group_by_gender.limit(1).organize

# this will return 1 gender item with 2 site items.
MyOrganizer.new.group_by_gender.limit(1).sort_site_id_by(2).organize
```

### Putting all together

Filters, groups, etc. can be chained to produce more accurate results...

```ruby
q = MyOrganizer.new
# apply default
q = q.skip_default_filters(:some_default_filter)
# filter collection by filter1
q = q.filter_by(:filter1)
# sort collection by age
q = q.sort_by(age: :desc)
# the result is grouped by site_id
q = q.group_by_site_id
# then, site group will by filtered by filter2
q = q.filter_site_id_by(:filter2)
# returns the result
q.organize
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/organizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
