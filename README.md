Fri Nov 8

Solo Project

Dan Baker


# Building ActiveRecordLite

In this project, we build our own lite version of ActiveRecord. The
purpose of this project is for you to understand how ActiveRecord
actually works: how your ActiveRecord world is translated into SQL.

## Warmup: Reimplement `attr_accessor`

Note: This is just a warmup -- you'll start ActiveRecord Lite in the
next section. **create a new file and test your `new_attr_accessor` by hand**.

You already know what the standard Ruby method `attr_accessor` does.
What if Ruby didn't provide this convenient method for you? Pretend
this is the case and implement the method `new_attr_accessor`, which
should do exactly the same thing as the real `attr_accessor`. This
should work for all `Object`s.

**Hint**: this would be an excellent time to investigate and use
`instance_variable_get` and `instance_variable_set` [here][ivar-get].

[ivar-get]: http://ruby-doc.org/core-2.0.0/Object.html#method-i-instance_variable_get

Here's an example of how `new_attr_accessor` should behave:

```ruby
class Cat
  new_attr_accessor :name, :color
end

> cat = Cat.new
> cat.name = "Sally"
> cat.color = "brown"

> cat.name # => "Sally"
> cat.color # => "brown"
```

## Setup

Check out the [skeleton git repo][skeleton-repo]. Click to download
the zip file (you don't need the whole repo). It has some basic tests
in the `spec/` directory. You can run them by running `rspec
spec/mass_object_spec.rb`.

[skeleton-repo]: https://github.com/appacademy-solutions/active_record_lite/tree/active-record-skeleton

You'll need to setup the SQLite3 database. You can do this by running:
`cat spec/cats.sql | sqlite3 spec/cats.db`. If your db gets bogus data
in it, you can always `rm spec/cats.db`, repopulate the db, and start
again.

## Phase I: `MassObject`

`MassObject` is a "blank" object that will be the base class for our
`Model` class. The job of `MassObject` is to implement an `initialize`
method that will accept a `hash` of attribute names and values,
assigning the values to instance variables. `MassObject` will also
provide setters and getters for the attributes.




```ruby
class MyClass < MassObject
  my_attr_accessible :x, :y
  my_attr_accessor :x, :y
end

my_obj = MyClass.new
my_obj.x = :x_val
my_obj.y = :y_val
```

Know the difference between `attr_accessor` and `attr_accessible`. Explain this difference to your TA.

* Write a class method `::my_attr_accessible(*attributes)`.
  should:
    * Iterate through the attributes
    * Store the array of attributes in a class instance variable,
        `@attributes`. This will act as our whitelist.
* Use your **seprate** class method `::my_attr_accessor` (that you built in the warm up).
    * Create setter/getter methods on the class for each attribute.
* Write a class getter method (`MassObject::attributes`) to fetch
  `@attributes`.
* Write a new `MassObject#initialize(params)` method. It should:
    * Iterate through each `attr_name, value` pair in the `params`
      hash
    * Check to see if `attr_name` is in the assigned attributes.
        * To check this, you may be tempted to write
          `MassObject.attributes.include?(attr_name)`. This is close,
          but you shouldn't call `attributes` directly on
          `MassObject`.
        * It's the *subclass* of `MassObject` which will have the
          `attributes`. How do you get the attributes of the subclass
          and not `MassObject` itself?
    * If so, use `send` to call the setter method and pass it the
      desired value.
    * Otherwise, raise an error: "mass assignment to unregistered
      attribute #{attr_name}"

Here's an example of how to use the method:

```ruby
class MyClass < MassObject
  my_attr_accessible :x, :y
  my_attr_accessor :x, :y
end

MyClass.new(:x => :x_val, :y => :y_val)
```

## Phase II: SQLObject

Our next job is to write a class, `SQLObject`, that will interact with
the database.

SQLite3 is back in your life. I've given you a helper class
`DBConnection` in `lib/active_record_lite/db_connection.rb`. You use
`execute`, pass it in SQL, as well as values to replace the `?`s in
the SQL.

**NOTE**: Table names can't be paramaterized using `?`. We can safely
string interpolate table names as they are hard coded into the classes.

* `SQLObject` should have a class method `set_table_name`. This should
  let the user specify the table on which to execute queries for this
  class. We should store the table name in a class instance variable.
* It should likewise have a `table_name` class getter method.
    * As a bonus, you may want to require the
      `active_support/inflector` library to get the
      `String#underscore` method and convert your class name to snake
      case by default for `SQLObject::table_name`.
    * You'll also have to use the inflector's ability to `#pluralize`.
* `SQLObject` should have a class method named `::all`. This should:
    * Query the specified table, selecting all rows and columns.
        * You will have to write a query and interpolate the table
          name into it.
        * Use `?` when interpolating values, but `execute` won't
          interpolate table names for you. You'll need to use the
          standard `#{}` Ruby interpolation.
    * Use the provided `DBConnection` class. Use
      `DBConnection.execute` freely in your `SQLObject` class.
    * For each row, call the `new` method, passing in the row hash.
    * `SQLObject` should inherit from `MassObject` so that we can
      mass-assign from the row hash.
    * When subclassing `SQLObject`, the user will have to call
      `my_attr_accessible` with the name of every column.
    * You may need to adjust your `MassObject#initialize` method
      slightly so that when it checks if a key in the passed params is
      included in the declared attributes, it first calls `#to_sym` on
      the key to turn it into a symbol.
    * This could otherwise be a problem because the SQLite3 gem
      returns hashes where the keys are strings (not symbols).
* Write a `SQLObject::find` method which takes an id. Write a query
  against the specified table from `set_table_name` for the row with
  the proper id. Do not return an `Array`; return either a single
  object or `nil`.
* Write a `SQLObject#create` instance method.
    * Execute a query that will create a record with the object's
      attribute values into the db.
    * Format: `INSERT INTO [table name] (comma sep attr names) VALUES
      (question marks)`
    * To get comma separated attribute names, get the array of
      attribute names and join them with `", "`.
    * To get a question marks string, create an array of question
      marks (maybe use something like `['?'] * 10`); join these with
      `", "`.
    * You'll need an array of the attribute values to insert; take the
      attribute names and use `send` to `map` them to the instance's
      values for those attributes.
    * When you execute the query, you need to pass in the SQL, plus
      all the attribute values. Use the "splat" (`*`) operator to do
      this.
    * After you `INSERT`, you need to set the object's `id` attribute
      with the newly issued row id.  Check out the `DBConnection` file
      for a helpful method.
* Write a `SQLObject#update` instance method
    * Same idea as `create`, but performs an `UPDATE [table_name] SET
      attr1 = ?, attr2 = ? WHERE id = [id]`
    * To piece this together, generate the "set line"; map the
      attribute names to `"#{attr_name} = ?"` and then join with `",
      "`.
    * Since you will again need an array of attribute values, factor
      out this functionality into a private `attribute_values` method.
* Write an instance method `SQLObject#save` that will call `#create`
  if `id` is `nil`; else it calls `#update`.
    * You can make `update`/`create` private now.

## Phase III: `Searchable`

Let's write a module named `Searchable`, where we'll define
`where`. By using `extend`, we can add the `Searchable` methods as
class methods of our `SQLObject`. At the same time, we can organize
our code by putting all search related methods in `Searchable` and
keep our code clean.

* Write a `Searchable` module.
* Write a `where` method. This should take a hash of column names and
  values.
    * Map the `#keys` of `params` to an array of `"#{key} = ?"`. Use
      this as the `WHERE` clause of the query.
    * Pass in the `#values` of the hash when executing the query.
* Mix the module into `SQLObject`, importing the methods as **class
  methods**.

## Phase IV: `Associatable`: `belongs_to`/`has_many`

* First, add a method `MassObject::parse_all`; this should take an
  array of result hashes, returning an array of parsed objects.
    * This should be convenient for your `where` and `all` methods.

### Part A: `belongs_to`

* Next, begin writing an `Associatable` module; we will `extend`
  `SQLObject` with this mix-in to add `belongs_to` and `has_many`
  class methods.

Begin writing a helper class, `BelongsToAssocParams`. The purpose of
this class will be to store the settings needed by the association to
execute a query. Let's see how it is used:

```ruby
name = "Cat"

settings = {
# We can either override, or have the class infer these values
#  :class_name => "Cat",
#  :foreign_key => "cat_id",
#  :primary_key => "id"
}

aps = BelongsToAssocParams.new(association_name, settings)

# if not provided in `settings`; take the association name and convert
# from `underscore` format to `camelcase`
aps.other_class_name == "Cat"

# if not provided in `settings`; use `id`
aps.primary_key == "id"

# if not provided, take the association name and add `_id` to the end
aps.foreign_key == "cat_id"

# use ActiveSupport's `String#constantize` method to go from the
# `String` `other_class_name` to the class object
aps.other_class == Cat

aps.other_table_name == Cat.table_name
```

In your `belongs_to` method, using your `BelongsToAssocParams` class
to help, use `define_method` to add a new method with the given
name. The method should make a SQL query; use `parse_all` after on the
`other_class` to return an array of model objects. Since `belongs_to`
should return (at most) one object, return it, and not an `Array`.

### Part B: `has_many`

As before, write a `HasManyAssocParams` class. You will need to
calculate all the values as before. However, note a few differences:

* `other_class_name` should `#singularize` the association name before
  converting it to `#camelcase`.
* `foreign_key` should take the current class' name, convert to
  snake\_case with `#underscore` and add `_id`.
    * For this reason, you should pass an extra argument (the current
      class), to `HasManyAssocParams#initialize`.

After doing this, it should be straightforward to again use
`define_method` to add a method that uses the params object to build
and execute a DB query.

## Phase V: `has_one_through`

### Part A: Storing association parameters

We're going to write a `has_one_through` method that will combine two
`belongs_to` associations. For instance:

```ruby
class Cat < SQLObject
  belongs_to :human
  has_one_through :house, :human, :house
end

class Human < SQLObject
  belongs_to :house
end

class House < SQLObject
end
```

`has_one_through` is going to need to make a query that uses and
combines the parameters (table names, foreign keys, primary keys) of
the two constituent associations.

To store the `belongs_to` parameters for later use by
`has_one_through`, put them in a class instance variable:

```ruby
class Cat < SQLObject
  # adds params to `@assoc_params`
  belongs_to :human
end

# later use
Cat.assoc_params[:human] == BelongsToAssocParams...
```

You'll need to modify your `belongs_to` very slightly to set
`assoc_params[:association_name]` to the params.

### Part B: Writing `has_one_through`

Again use `define_method` to write a method that will execute a DB
query. Look up the params for the two associations. Once you have
gotten these, think up the query that will work. **Hint**: you'll need
one join.

As with `belongs_to`, don't return an `Array`.

#### A Common Mistake

There's a common mistake that everyone makes. In the `has_one_through`
method, before defining the method to fetch the associated objects,
people will first ask for the association parameters for the two
constituent associations. Let me show what is wrong with this:

```ruby
class Cat < SQLObject
  belongs_to :human

  # XXX: The `Human` class is not defined yet; much less are any
  # associations defined on `Human` yet. If `has_one_through` tries to
  # access `Human::assoc_params`, this will fail. In fact,
  # `"Human".constantize` won't even work, because `Human` has not
  # been defined yet.
  has_one_through :house, :human
end

class Human < SQLObject
  belongs_to :house
end

class House < SQLObject
end
```

When the `has_one_through` method is called, Ruby hasn't gotten to the
definition of the `Human` class yet. Trying to access either `Human`
or its association params **will not work**. The upshot is that we
cannot access other classes' association parameters from
`has_one_through`.

However, `has_one_through` defines a method (here `Cat#house`). By the
time this method is called, you can assume all the loaded classes will
have been read and that all the other associations have been set
up. Can you wait until after the association fetch method is called to
fetch the required parameters?

## Extension Ideas

0. Write `where` so that it is lazy and stackable. Implement a
  `Relation` class.
0. Write an `includes` method that does pre-fetching.
0. `has_many :through`
    * This should handle both `belongs_to => has_many` and `has_many
      => belongs_to`.
0. Validation methods/validator classes
0. `joins`
