# Koos

Koos is an ORM designed for convenience and ease of use, it is modeled after DBIx::\* if you're into that kind of thing already (note: some concepts and names have deviated).  

[![Build Status](https://travis-ci.org/tony-o/perl6-koos.svg?branch=master)](https://travis-ci.org/tony-o/perl6-koos)

## what works

* relationships
* row object inflation (calling .first on a query returns a Koos::Row)
* row objects inherit from the model::@columns
* model level convenience methods
* row level convenience methods
* basic handling compounded primary keys
* column validation hooks

## todo

* decouple SQL generation from Koos::Searchable (this includes decoupling the SQL generation from the DB layer)
* look at possibility of YAML (or something else) generation of models
* soft validation of model/table/relationships when model loads
* prefetch relationships option

# Usage

Below is a minimum viable model setup for your app.  Koos does _not_ create the table for you, that is up to you.

### lib/app.pm6
```perl6
use Koos;

my Koos $d .=new;

$d.connect(
  driver => 'SQLite',
  options => {
    db => {
      database => '/tmp/xyz.sqlite3',
    },
  },
);

my $customer-model = $d.model('Customer');
my $new-customer   = $customer-model.new-row;
$new-customer.name('xyz co');
$new-customer.rate(150);
$new-customer.update; # runs an insert because this is a new row

my $xyz = $customer-model.search({ name => { 'like' => '%xyz%' } }).first;
$xyz.rate( $xyz.rate * 2 ); #twice the rate!
$xyz.update; # UPDATEs the database

my $xyz-orders = $xyz.orders.count;
```

### lib/Model/Customer.pm6
```perl6
use Koos::Model;
unit class Model::Customer does Koos::Model['customer'];

has @.columns = [
  id => {
    type           => 'integer',
    nullable       => False,
    is-primary-key => True,
    auto-increment => 1,
  },
  name => {
    type           => 'text',
  },
  rate => {
    type => 'integer',
  },
];

has @.relations = [
  orders => { :has-many, :model<Order>, :relate(id => 'customer_id') },
];
```

# role Koos::Model

What is a model?  A model is essentially a table in your database.  Your ::Model::X is pretty barebones, in this module you'll defined `@.columns` and `@.relations` (if there are any relations).

## Example

```perl6
use Koos::Model;
# the second argument below is optional and also accepts a type.
# if the arg is omitted then it attempts to auto load ::Row::Customer
# if it fails to auto load then it uses an anonymous Row and adds convenience methods to that
unit class X::Model::Customer does Koos::Model['customer', 'X::Row::Customer']; 

has @.columns = [
  id => {
    type           => 'integer',
    nullable       => False,
    is-primary-key => True,
    auto-increment => 1,
  },
  name => {
    type           => 'text',
  },
  contact => {
    type => 'text',
  },
  country => {
    type => 'text',
  },
];

has @.relations = [
  orders => { :has-many, :model<Order>, :relate(id => 'customer_id') },
  open_orders => { :has-many, :model<Order>, :relate(id => 'customer_id', '+status' => 'open') },
  completed_orders => { :has-many, :model<Order>, :relate(id => 'customer_id', '+status' => 'closed') },
];

# down here you can have convenience methods

method delete-all { #never do this in real life
  die '.delete-all disabled in prod or if %*ENV{in-prod} not defined'
    if !defined %*ENV{in-prod} || so %*ENV{in-prod};
  my $s = self.search({ id => { '>' => -1 } });
  $s.delete;
  !so $s.count;
}

```

In this example we're creating a customer model with columns `id, name, contact, country` and relations with specific filter criteria.  You may notice the `+status => 'open'` on the open\_orders relationship, the `+` here indicates it's a filter on the original table.

### Breakdown

`class :: does Koos::Model['table-name', 'Optional String or Type'];`

Here you can see the role accepts one or two parameters, the first is the DB table name, the latter is a String or Type of the row you'd like to use for this model.  If no row is found then Koos will create a generic row and add helper methods for you using the model's column data.

`@.columns`

A list of columns in the table.  It is highly recommended you have *one* `is-primary-key` or `.update` will have unexpected results.

`@.relations`

This accepts a list of key values, the key defining the accessor name, the later a hash describing the relationship.  `:has-one` and `:has-many` are both used to dictate whether a Koos model returns an inflated object (:has-one) or a filterable object (:has-many).

## Methods

### `search(%filter?, %options?)`

Creates a new filterable model and returns that.  Every subsequent call to `.search` will _add_ to the existing filters and options the best it can.

Example:

```
my $customer = $dbo.model('Customer').search({ name => { like => '%bozo%' }, });
# later on ...
my $geo-filtered-customers = $customer.search({ country => 'usa' });
# $geo-filtered-customers effective filter is:
#   {
#      name => { like => '%bozo%' },
#      country => 'usa',
#   }
```

### `.all(%filter?)`

Returns all rows from query (an array of inflated `::Row::XYZ`).  Providing `%filter` is the same as doing `.search(%filter).all` and is provided only for convenience.

### `.first(%filter?, :$next = False)`

Returns the first row (again, inflated `::Row::XYZ`) and caches the prepared statement (this is destroyed and ignored if $next is falsey)

### `.next(%filter?)`

Same as calling `.first(%filter, :next)`

### `.count(%filter?)`

Returns the result of a `select count` for the current filter selection.  Providing `%filter` results in `.search(%filter).count`

### `.delete(%filter?)`

Deletes all rows matching criteria.  Providing `%filter` results in `.search(%filter).delete`

### `.new-row(%field-data?)`

Creates a new row with %field-data.

## Convenience methods

Koos::Model inheritance allows you to have convenience methods, these methods can act on whatever the current set of filters is.

Consider the following:

Convenience model definition:

```perl6
class X::Model::Customer does Koos::Model['customer'];

# columns and relations

method remove-closed-orders {
  self.closed_orders.delete;
}
```

Later in your code:

```perl6
my $customers = $dbo.model('Customer');

my $all-customers    = $customers.search({ id => { '>' => -1 } });
my $single-customers = $customers.search({ id => 5 });

$all-customers.remove-closed-orders;
# this removes all orders for customers with an id > -1
$single-customer.remove-closed-orders;
# this removes all orders for customers with id = 5
```

# role Koos::Row

A role to apply to your `::Row::Customer`.  If there is no `::Row::Customer` a generic row is created using the column and relationship data specified in the corresponding `Model` and this file is only really necessary if you want to add convenience methods.

When a `class :: does Koos::Row`, it receives the info from the model and adds the methods for setting/getting field data.

With the model definition above:

```perl6
my $invoice-model = $dbo.model('invoice');
my $invoice = $invoice-model.new-row({
  customer_id => $customer.id,
  amount      => 400,
});  # this $invoice is NOT in the database until .update

my $old-amount = $invoice.amount; # = 400
$invoice.amount($invoice.amount * 2);
my $new-amount = $invoice.amount; # = 800

$invoice.update;
```

If there is a collision in the naming conventions between your model and the row then you'll need to use `[set|get]-column`

## Methods

### `.duplicate`

Duplicates the row omitting the `is-primary-key` field so the subsequent `.save` results in a new row rather than updating

### `.as-hash`

Returns the current field data for the row as a hash.  If there has been unsaved updates to fields then it returns _those_ values instead of what is in the database.  You can determine whether the row has field-changes with `is-dirty`

### `.set-column(Str $key, $value)`

Updates the field data for the column (not stored in database until `.update` is called).  If you want to `.wrap` a field setter for a certain key, wrap this and filter for the key

### `.get-column(Str $key)`

Retrieves the value for `$key` with any field changes having priority over data in database, use `.is-dirty`

### `.get-relation(Str $column, :%spec?)`

It is recommended any Model with a relationship name that conflicts and causes no convenience method to be generated be renamed, but use this if you must. `$customer.orders` is calling essentially `$customer.get-relation('orders')`.  Do not provide `%spec` unless you know what you're doing.

### `.update`

Saves the row in the database.  If the field with a positive `is-primary-key` is _set_ then it runs and `UPDATE ...` statement, otherwise it `INSERT ...`s and updates the Row's `is-primary-key` field.  Ensure you set one field with `is-primary-key`
