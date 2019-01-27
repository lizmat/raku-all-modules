# Welcome to Xoos

This is the documentation for Xoos, a perl6 ORM.  this document is incomplete.
##

* [terminology](#terminology)
  * [model](#model)
  * [row](#row)
* [order of operations](#order-of-operations)
  * [bootstrapping](#bootstrapping)
    * [connect](#connect)
      * [options](#options)
        * [$prefix](#prefix)
        * [@model-dirs](#model-dirs)
      * [DSN vs DB](#dsn-vs-db)
        * [DSN](#dsn)
        * [DB](#db)
* [models](#models)
  * [referencing the model](#referencing-the-model)
    * [.table-name](#table-name)
    * [.db](#db)
    * [.driver](#driver)
    * [.row-class](#row-class)
    * [.new-row](#new-row)
    * [.search(%filter?, %options?)](#searchfilter-options)
      * [search %filter](#searchfilter)
    * [.dump-filter](#dump-filter)
    * [.dump-options](#dump-options)
    * [.all(%filter?)](#allfilter)
    * [.first(%filter?, :$next = False)](#firstfilter-next--false)
    * [.next(%filter?)](#nextfilter)
    * [.count(%filter?)](#countfilter)
    * [.update(%values, %filter?)](#updatevalues-filter)
    * [.delete(%filter?)](#deletefilter)
    * [.insert(%field-data)](#insertfield-data)
* [yaml model files](#yaml-model-files)


# terminology

## model

a model describes a table.  anything in your `Model/` can contain methods to act upon that data, ie `Model::Customer` might contain a convenience method `outstanding-invoice-balance` that returns the monetary value of all unpaid invoices

## row

describes a row of the table.  anything in your `Row/` can contain methods to act upon one data, ie 'Row::Invoice` might contain a method `mark-paid` that marks the invoice paid and updates your other accounting tables.  the row class file is optional if you're not going to put anything into it then Xoos will create an anonymous row class that will act as the template object for conflating rows

# order of operations

## bootstrapping

### .connect

`connect` is overloaded as `connect(Any:D: :$db, :%options)` or `connect(Str:D $dsn, :%options)`.  More about DSN vs DB below.

This method is templated in `DB::Xoos` and implemented in the respective `DB::Xoos::<Driver>`, see those files for more in depth in what is happening in the one you're interested in.

When connect is called, models and rows loading is attempted with any problems `warn`ed to stdout.

#### `%options`

##### `$prefix`

This is the prefix to use when attempting to load Models.  ie `:prefix<X>` attempts to load models and rows from `X/Model|Row/\*`

##### `@model-dirs`

Use this option to load models and rows from YAML files

#### DSN vs DB

##### DSN

you can use either a DSN or use an existing DB connection to start Xoos.

DSN format is `<driver>://(<user>:<pass>@)?<host>(:<port>)?/(<database>)?`.  the database name is optional for drivers like `sqlite`

##### DB

Xoos ships with `MySQL|Oracle|Pg|SQLite` and they all use `DBIish`, if you need to use `DB::Pg` then please consider contributing either to the ecosystem or this repo and use `DB::Xoos::Pg\(::\*\)` as a template

You can pass `.connect` an existing connection


# models

models should inherit from `DB::Xoos::Model[Str:D $table-name, Str:D $row-class?]` where `$table-name` is mandatory and `$row-class` will attempt to auto load the `Row` class based on the model's name

## referencing the model

after Xoos is `.connected` you can obtain the loaded model via `$xoos.model('model-name')`.  in the returned object you'll be able to call any of the following methods plus any defined in your model's class

### `.table-name`

returns the name of the table the model is using

### `.db`

returns the raw db connection

### `.driver`

returns the driver the ORM is using

### `.row-class`

returns the raw row-class the model is using to conflate

### `.new-row`

creates and returns and _unsaved_ new row for the model

### `.search(%filter?, %options?)`

returns a reference to the model class with the filter cached and the sql (lazily) cached.  in this way you can chain sub searches and inherit filters with the sub-search filter overriding the parent

```perl6
my $search = $customer.search({ id => { '>' => 0 } });
my $sub-search = $search.search({ name => { 'like' => 'a%' } });
my $destructive-sub = $sub-search.search({ id => { '<' => 5 } });

# search filter:           where id > 0;
# sub-search filter:       where id > 0 and name like 'a%';
# desctructive-sub filter: where id < 5 and name like 'a%';

my $customer-id-only = $customer.search({}, {
  fields => [qw<id>],
}).first; #only the .id field in the customer row is fetched/filled
```

#### search %filter

defines what you're looking for in you row search

### `.dump-filter`

returns the current filter for the search object

### `.dump-options`

returns the current options for the search object

### `.all(%filter?)`

returns all of the rows with the search criteria (or all if no search criteria is given).  also allows you to pass a new (inherited from the search object or model depending on the method of calling) for convenience

```perl6
my @customers = $xoos.model('Customer').all; #all customers
my @a-customers = $xoos.model('Customer').all({ name => { 'like' => 'a%' } }); # all customers where name starts with a
```

### `.first(%filter?, :$next = False)`

instantiates a cursor for first/next (you can use this method to get next by passing :next).

### `.next(%filter?)`

returns the next row for the cursor

### `.count(%filter?)`

returns a `count(\*)` query for the inherited filter

### `.update(%values, %filter?)`

updates all rows with the given values for the inherited filter

### `.delete(%filter?)`

deletes all rows matching the inherited filter, calling this on a `.model(<>)` will empty the table.

### `.insert(%field-data)`

inserts the given field-data into the table and returns `Nil`

## searching the model

### and vs or

the default search method is `and`:

```perl6
$model.search({ id => { '>' => 100 }, name => { 'like' => 'a%' } });

# where id > 100 and name like 'a%'
```

if you'd like to generate an `or` or use an `and` nested within an or you can do that by prefixing it with `-`

```perl6
$model.search({
  '-or' => [
    ( id => { '>' => 100 }),
    ( id => { '<' => 999 }),
    [
      ( name          => { 'like' => 'a%' }),
      ( sales_channel => 'web' ),
    ],
  ]
});

# where id > 100 or id < 999 or (name like 'a%' AND "sales_channel" = 'web');
```

# yaml model files

yaml model files are optional and ultimately depend on how you want to look at the structure of your tables in code.  the format of the yaml file is very similar to the perl6 format but here might be a typical layout (see model documentation for more info about what these options mean)

```yaml
table: customer
name: Customer
columns:
  customer_id:
    type: integer
    nullable: false
    is-primary-key: true
    auto-increment: true
  name:
    type: text
  relations:
    invoice:
      has-many: true
      model: Invoice
      relate:
        invoice_id: customer_id
    open-invoices:
      has-many: true
      model: Invoice
      relate:
        invoice_id: customer_id
        +status: closed
```
