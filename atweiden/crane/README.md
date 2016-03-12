# Crane

<!-- intro {{{ -->

Navigate Perl6 [containers](http://doc.perl6.org/language/containers)
and perform tasks.

<!-- end intro }}} -->


<!-- synopsis {{{ -->

## Synopsis

<!-- example code {{{ -->

```perl6
use Crane;

my %h0;
my %h1 = Crane.add(%h0, :path['a'], :value({:b({:c<here>})}));
my %h2 = Crane.add(%h1, :path(qw<a b d>), :value([]));
my %h3 = Crane.add(%h2, :path(|qw<a b d>, 0), :value<diamond>);
my %h4 = Crane.replace(%h3, :path(|qw<a b d>, *-1), :value<dangerous>);
my %h5 = Crane.remove(%h4, :path(qw<a b c>));
my %h6 = Crane.move(%h5, :from(qw<a b d>), :path['d']);
my %h7 = Crane.copy(%h6, :from(qw<a b>), :path['b']);
my %h8 = Crane.remove(%h7, :path(qw<a b>));
my %h9 = Crane.replace(%h8, :path['a'], :value(['alligators']));
my %h10 = Crane.replace(%h9, :path['b'], :value(['be']));

say Crane.list(%h10).perl;
(
    {:path(["a", 0]), :value("alligators")},
    {:path(["b", 0]), :value("be")},
    {:path(["d", 0]), :value("dangerous")}
)
```

<!-- end example code }}} -->

-------------------------------------------------------------------------------

<!-- end synopsis }}} -->


<!-- description {{{ -->

## Description

Crane aims to be for Perl6 containers what [JSON
Pointer](http://tools.ietf.org/html/rfc6901) and [JSON
Patch](http://tools.ietf.org/html/rfc6902) are for JSON.

### Features

- add, remove, replace, move, copy, test operations
- get/set
- diff/patch
- list the contents of a nested data structure in accessible format

-------------------------------------------------------------------------------

<!-- end description }}} -->


<!-- exported subroutines {{{ -->

## Exported Subroutines

<!-- exported subroutines toc {{{ -->

- [`at($container,*@path)`](#atcontainerpath)
- [`in($container,*@path)`](#incontainerpath)

<!-- end exported subroutines toc }}} -->

<!-- at($container,*@path) {{{ -->

### `at($container,*@path)`

Navigates to and returns container `is rw`.

_arguments:_

* `$container`: _Container, required_ — the target container
* `*@path`: _Path, optional_ — a list of steps for navigating container

_returns:_

* Container at path (`is rw`)

_example:_

```perl6
my %inxi = :info({
    :memory([1564.9, 32140.1]),
    :processes(244),
    :uptime<3:16>
});

at(%inxi, 'info')<uptime>:delete;
at(%inxi, qw<info memory>)[0] = 31868.0;

say %inxi.perl; # :info({ :memory(31868.0, 32140.1), :processes(244) })
```

<!-- end at($container,*@path) }}} -->

<!-- in($container,*@path) {{{ -->

### `in($container,*@path)`

`in` works like `at`, except `in` will create the structure of nonexisting
containers based on `@path` input instead of aborting the operation, e.g.

```perl6
at(my %h, qw<a b c>) = 5 # ✗ Crane error: associative key does not exist
in(my %i, qw<a b c>) = 5
say %i.perl;
{
    :a({
        :b({
            :c(5)
        })
    })
}
```

If `@path` contains keys that lead to a nonexisting container, the default
behavior is to create a Positional container there if the key is an
`Int >= 0` or a `WhateverCode`. Otherwise `in` creates an Associative
container there, e.g.

```perl6
my %h;
in(%h, qw<a b>, 0, *-1) = 'here';
say %h.perl;
{
    :a({
        :b([
            ["here"]
        ])
    })
}
```

If `@path` contains keys that lead to an existing Associative container,
it will attempt to index the existing Associative container with the
key regardless of the key's type (be it `Int` or `WhateverCode`), e.g.

```perl6
my @a = [ :i({:want({:my<MTV>})}) ];
in(@a, 0, 'i', 'want', 2) = 'always';
say @a.perl;
[
    :i({
        :want({
            "2" => "always",
            :my("MTV")
        })
    })
]

my @b = [ :i({:want(['my', 'MTV'])}) ];
in(@b, 0, 'i', 'want', 2) = 'always';
say @b.perl;
[
    :i({
        :want(["my", "MTV", "always"])
    })
]
```

_arguments:_

* `$container`: _Container, required_ — the target container
* `*@path`: _Path, optional_ — a list of steps for navigating container

_returns:_

* Container at path (`is rw`)

_example:_

```perl6
my %archversion = :bamboo({ :up<0.0.1>, :aur<0.0.2> });
in(%archversion, qw<fzf up>) = '0.11.3';
in(%archversion, qw<fzf aur>) = '0.11.3';
say %archversion.perl;
{
    :bamboo({ :aur<0.0.2>, :up<0.0.1> }),
    :fzf({ :aur<0.11.3>, :up<0.11.3> })
}
```

<!-- end in($container,*@path) }}} -->

-------------------------------------------------------------------------------

<!-- end exported subroutines }}} -->


<!-- methods {{{ -->

## Methods

<!-- methods toc {{{ -->

- [`.exists($container,:@path!,:$k,:$v)`](#existscontainerpathkv)
- [`.get($container,:@path!,:$k,:$v,:$p)`](#getcontainerpathkvp)
- [`.set($container,:@path!,:$value!)`](#setcontainerpathvalue)
- [`.add($container,:@path!,:$value!,:$in-place)`](#addcontainerpathvaluein-place)
- [`.remove($container,:@path!,:$in-place)`](#removecontainerpathin-place)
- [`.replace($container,:@path!,:$value!,:$in-place)`](#replacecontainerpathvaluein-place)
- [`.move($container,:@from!,:@path!,:$in-place)`](#movecontainerfrompathin-place)
- [`.copy($container,:@from!,:@path!,:$in-place)`](#copycontainerfrompathin-place)
- [`.test($container,:@path!,:$value!)`](#testcontainerpathvalue)
- [`.list($container,:@path)`](#listcontainerpath)
- [`.flatten($container,:@path)`](#flattencontainerpath)
- [`.transform($container,:@path!,:&with!,:$in-place)`](#transformcontainerpathwithin-place)
- [`.patch($container,@patch,:$in-place)`](#patchcontainerpatchin-place)

<!-- end methods toc }}} -->

<!-- example data structure {{{ -->

All example code assumes `%data` has this structure:

```perl6
my %data =
    :legumes([
        {
            :instock(4),
            :name("pinto beans"),
            :unit("lbs")
        },
        {
            :instock(21),
            :name("lima beans"),
            :unit("lbs")
        },
        {
            :instock(13),
            :name("black eyed peas"),
            :unit("lbs")
        },
        {
            :instock(8),
            :name("split peas"),
            :unit("lbs")
        }
    ]);
```

<!-- end example data structure }}} -->

<!-- .exists($container,:@path!,:$k,:$v) {{{ -->

### `.exists($container,:@path!,:$k,:$v)`

Determines whether a key exists in the container at the
specified path. Works similar to the p6 Hash `:exists` [subscript
adverb](http://doc.perl6.org/type/Hash#%3Aexists). Pass the `:v` flag to
determine whether a defined value is paired to the key at the specified
path.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$k`: _Bool, optional, defaults to True_ — indicates whether to
         check for an existing key at path
* `:$v`: _Bool, optional_ — indicates whether to check for a defined
         value at path

_returns:_

* `True` if exists, otherwise `False`

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.
Passing `:v` flag tests `if $container.defined`. Default behavior is to
raise an error as key operations aren't permitted on root containers.

<!-- end .exists($container,:@path!,:$k,:$v) }}} -->

<!-- .get($container,:@path!,:$k,:$v,:$p) {{{ -->

### `.get($container,:@path!,:$k,:$v,:$p)`

Gets the value from container at the specified path. The default
behavior is to raise an error if path is nonexistent.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$k`: _Bool, optional_ — only return the key at path
* `:$v`: _Bool, optional, defaults to True_ — only return the value
         at path
* `:$p`: _Bool, optional_ — return the key-value pair at path

_returns:_

* the dereferenced key, value or key-value pair

_example:_

```perl6
my $value = Crane.get(%data, :path('legumes', 1));
say $value.perl; # { :instock(21), :name("lima beans"), :unit("lbs") }

my $value-k = Crane.get(%data, :path('legumes', 1), :k);
say $value-k.perl; # 1

my $value-p = Crane.get(%data, :path('legumes', 1), :p);
say $value-p.perl; # 1 => { :instock(21), :name("lima beans"), :unit("lbs") }
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

- if `:v` flag passed (the default): `return $container`
- if `:k` flag passed: raise error "Sorry, not possible to request key
                       operations on the container root"
- if `:p` flag passed: raise error "Sorry, not possible to request key
                       operations on the container root"

<!-- end .get($container,:@path!,:$k,:$v,:$p) }}} -->

<!-- .set($container,:@path!,:$value!) {{{ -->

### `.set($container,:@path!,:$value!)`

Sets the value at the specified path in the container. The default
behavior is to create nonexistent paths (similar to `mkdir -p`).

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$value!`: _Any, required_ — the value to be set at the specified path

_returns:_

* Modified container

_example:_

```perl6
my %p;
Crane.set(%p, :path(qw<peter piper>), :value<man>);
Crane.set(%p, :path(qw<peter pan>), :value<boy>);
Crane.set(%p, :path(qw<peter pickle>), :value<dunno>);
say %p.perl; # { :peter({ :pan("boy"), :pickle("dunno"), :piper("man") }) }
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

```perl6
my $a = (1, 2, 3);
Crane.set($a, :path(), :value<foo>);
say $a; # foo
```

<!-- end .set($container,:@path!,:$value!) }}} -->

<!-- .add($container,:@path!,:$value!,:$in-place) {{{ -->

### `.add($container,:@path!,:$value!,:$in-place)`

Adds a value to the container. If `:@path` points to an existing item
in the container, that item's value is replaced.

In the case of a `Positional` type, the value is inserted before the
given index. Use the relative accessor (`*-0`) instead of an index
(`Int`) for appending to the end of a `Positional`.

Because this operation is designed to add to existing `Associative` types,
its target location will often not exist. However, an `Associative`
type or a `Positional` type containing it does need to exist, and it
remains an error for that not to be the case. For example, a `.add`
operation with a target location of `<a b>` starting with this Hash:

```perl6
{ :a({ :foo(1) }) }
```

is not an error, because "a" exists, and "b" will be added to its
value. It is an error in this Hash:

```perl6
{ :q({ :bar(2) }) }
```

because "a" does not exist.

Think of the `.add` operation as behaving similarly to `mkdir`, not
`mkdir -p`. For example, you cannot do (in shell):

```
$ ls # empty directory
$ mkdir a/b/c
mkdir: cannot create directory ‘a/b/c’: No such file or directory
```

Without the `-p` flag, you'd have to do:

```
$ ls # empty directory
$ mkdir a
$ mkdir a/b
$ mkdir a/b/c
```

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$value!`: _Any, required_ — the value to be added/inserted at the
              specified path
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %legume = :name<carrots>, :unit<lbs>, :instock(3);
my %data-new = Crane.add(%data, :path('legumes', 0), :value(%legume));
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

```perl6
my @a;
my @b = Crane.add(@a, :path([]), :value<foo>);
say @a.perl; # []
say @b.perl; # ["foo"]
```

<!-- end .add($container,:@path!,:$value!,:$in-place) }}} -->

<!-- .remove($container,:@path!,:$in-place) {{{ -->

### `.remove($container,:@path!,:$in-place)`

Removes the pair at path from `Associative`
types, similar to the p6 Hash `:delete` [subscript
adverb](http://doc.perl6.org/type/Hash#%3Adelete). Splices elements out
from `Positional` types.

The default behavior is to raise an error if the target location is
nonexistent.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %h = :example<hello>;
my %h2 = Crane.remove(%h, :path(['example']));
say %h.perl; # { :example<hello> }
say %h2.perl; # {}
```

This:

```perl6
%h<a><b>:delete;
```

is equivalent to this:

```perl6
Crane.remove(%h, :path(qw<a b>));
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

```perl6
my $a = [1, 2, 3];
my $b = Crane.remove($a, :path([])); # equivalent to `$a = Empty`
say $a.perl; [1, 2, 3]
say $b; # (Any)
```

<!-- end .remove($container,:@path!,:$in-place) }}} -->

<!-- .replace($container,:@path!,:$value!,:$in-place) {{{ -->

### `.replace($container,:@path!,:$value!,:$in-place)`

Replaces a value. This operation is functionally identical to a `.remove`
operation for a value, followed immediately by a `.add` operation at
the same location with the replacement value.

The default behavior is to raise an error if the target location is
nonexistent.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$value!`: _Any, required_ — the value to be set at the specified path
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %legume = :name("green beans"), :unit<lbs>, :instock(3);
my %data-new = Crane.replace(%data, :path('legumes', 0), :value(%legume));
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

```perl6
my %a = :a<aaa>, :b<bbb>, :c<ccc>;
my %b = Crane.replace(%a, :path([]), :value({ :vm<moar> }));
say %a.perl; # { :a<aaa>, :b<bbb>, :c<ccc> }
say %b.perl; # { :vm<moar> }
```

<!-- end .replace($container,:@path!,:$value!,:$in-place) }}} -->

<!-- .move($container,:@from!,:@path!,:$in-place) {{{ -->

### `.move($container,:@from!,:@path!,:$in-place)`

Moves the source value identified by `@from` in container to destination
location specified by `@path`. This operation is functionally identical
to a `.remove` operation on the `@from` location, followed immediately
by a `.add` operation at the `@path` location with the value that was
just removed.

The default behavior is to raise an error if the source is nonexistent.

The default behavior is to raise an error if the `@from` location is a
proper prefix of the `@path` location; i.e., a location cannot be moved
into one of its children.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@from!`: _Path, required_ — a list of steps to the source
* `:@path!`: _Path, required_ — a list of steps to the destination
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_What about operating on the root of the container?_

Pass an empty list as `@from` or `@path` to operate on the root of
the container.

<!-- end .move($container,:@from!,:@path!,:$in-place) }}} -->

<!-- .copy($container,:@from!,:@path!,:$in-place) {{{ -->

### `.copy($container,:@from!,:@path!,:$in-place)`

Copies the source value identified by `@from` in container to destination
container at location specified by `@path`. This operation is functionally
identical to a `.add` operation at the `@path` location using the value
specified in the `@from`. As with `.move`, a location cannot be copied
into one of its children.

The default behavior is to raise an error if the source at `@from`
is nonexistent.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@from!`: _Path, required_ — a list of steps to the source
* `:@path!`: _Path, required_ — a list of steps to the destination
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %h = :example<hello>;
my %h2 = Crane.copy(%h, :from(['example']), :path(['sample']));
say %h.perl; # { :example("hello") }
say %h2.perl; # { :example("hello"), :sample("hello") }
```

_What about operating on the root of the container?_

Pass an empty list as `@from` or `@path` to operate on the root of the
container. Has similar rules / considerations to `.move`.

<!-- end .copy($container,:@from!,:@path!,:$in-place) }}} -->

<!-- .test($container,:@path!,:$value!) {{{ -->

### `.test($container,:@path!,:$value!)`

Tests that the specified value is set at the target location in the
document.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps for navigating container
* `:$value!`: _Any, required_ — the value expected at the specified path

_returns:_

* `True` if expected value exists at `@path`, otherwise `False`

_example:_

```perl6
say so Crane.test(%data, :path('legumes', 0, 'name'), :value("pinto beans")); # True
```

_What about operating on the root of the container?_

Pass an empty list as `@path` to operate on the root of the container.

<!-- end .test($container,:@path!,:$value!) }}} -->

<!-- .list($container,:@path) {{{ -->

### `.list($container,:@path)`

Lists all of the paths available in `$container`.

_arguments:_

* `$container` : _Container, required_ — the target container
* `:@path`: _Path, optional_ — a list of steps for navigating container

_returns:_

* List of path-value pairs

_example:_

Listing a `Hash`:

```perl6
say Crane.list(%data);
(
    {
        :path(["legumes", 0, "instock"]),
        :value(4)
    },
    {
        :path(["legumes", 0, "name"]),
        :value("pinto beans")
    },
    {
        :path(["legumes", 0, "unit"]),
        :value("lbs")
    },
    {
        :path(["legumes", 1, "instock"]),
        :value(21)
    },
    {
        :path(["legumes", 1, "name"]),
        :value("lima beans")
    },
    {
        :path(["legumes", 1, "unit"]),
        :value("lbs")
    },
    {
        :path(["legumes", 2, "instock"]),
        :value(13)
    },
    {
        :path(["legumes", 2, "name"]),
        :value("black eyed peas")
    },
    {
        :path(["legumes", 2, "unit"]),
        :value("lbs")
    },
    {
        :path(["legumes", 3, "instock"]),
        :value(8)
    },
    {
        :path(["legumes", 3, "name"]),
        :value("split peas")
    },
    {
        :path(["legumes", 3, "unit"]),
        :value("lbs")
    }
)
```

Listing a List:

```perl6
my $a = qw<zero one two>;
say Crane.list($a);
(
    {
        :path([0]),
        :value("zero")
    },
    {
        :path([1]),
        :value("one")
    },
    {
        :path([2]),
        :value("two")
    }
)
```

<!-- end .list($container,:@path) }}} -->

<!-- .flatten($container,:@path) {{{ -->

### `.flatten($container,:@path)`

Flattens a container into a single-level `Hash` of path-value pairs.

_arguments:_

* `$container` : _Container, required_ — the target container
* `:@path`: _Path, optional_ — a list of steps for navigating container

_returns:_

* a flattened `Hash` of path-value pairs.

_example:_

```perl6
say Crane.flatten(%data);
{
    ("legumes", 0, "instock") => 4,
    ("legumes", 0, "name")    => "pinto beans",
    ("legumes", 0, "unit")    => "lbs",
    ("legumes", 1, "instock") => 21,
    ("legumes", 1, "name")    => "lima beans",
    ("legumes", 1, "unit")    => "lbs",
    ("legumes", 2, "instock") => 13,
    ("legumes", 2, "name")    => "black eyed peas",
    ("legumes", 2, "unit")    => "lbs",
    ("legumes", 3, "instock") => 8,
    ("legumes", 3, "name")    => "split peas",
    ("legumes", 3, "unit")    => "lbs"
}
```

<!-- end .flatten($container,:@path) }}} -->

<!-- .transform($container,:@path!,:&with!,:$in-place) {{{ -->

### `.transform($container,:@path!,:&with!,:$in-place)`

Functionally identical to a `replace` operation with the replacement value
being the return value of `with` applied to the value of `$container`
at `@path`.

The Callable passed in `with` must take one (optional) positional argument
and return a value.

_arguments:_

* `$container`: _Container, required_ — the target container
* `:@path!`: _Path, required_ — a list of steps to the destination
* `:&with!`: _Callable, required_ — instructions for changing the
             value at `@path`
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %market =
    :foods({
        :fruits([qw<blueberries marionberries>]),
        :veggies([qw<collards onions>])
    });

my @first-fruit = |qw<foods fruits>, 0;
my @second-veggie = |qw<foods veggies>, 1;

my &oh-yeah = -> $s { $s ~ '!' };

Crane.transform(%market, :path(@first-fruit), :with(&oh-yeah), :in-place);
say so Crane.get(%market, :path(@first-fruit)) eq 'blueberries!'; # True

Crane.transform(%market, :path(@second-veggie), :with(&oh-yeah), :in-place);
say so Crane.get(%market, :path(@second-veggie)) eq 'onions!'; # True
```

<!-- end .transform($container,:@path!,:&with!,:$in-place) }}} -->

<!-- .patch($container,@patch,:$in-place) {{{ -->

### `.patch($container,@patch,:$in-place)`

Apply `@patch`, a list of specially formatted Hashes representing
individual 6902 operations implemented by Crane, to `$container`.

**add**

```perl6
{ :op("add"), :path(qw<path to target>), :value("Value") }
```

**remove**

```perl6
{ :op("remove"), :path(qw<path to target>) }
```

**replace**

```perl6
{ :op("replace"), :path(qw<path to target>), :value("Value") }
```

**move**

```perl6
{ :op("move"), :from(qw<path to source>), :path(qw<path to target>) }
```

**copy**

```perl6
{ :op("copy"), :from(qw<path to source>), :path(qw<path to target>) }
```

**test**

```perl6
{ :op("test"), :path(qw<path to target>), :value("Is value") }
```

If an operation is not successful, the default behavior is to raise an
exception. If a test operation as part of the `@patch` returns False,
the default behavior is to raise an exception.

_arguments:_

* `$container`: _Container, required_ — the target container
* `@patch`: _Patch, required_ — a list of 6902 instructions to apply
* `:$in-place`: _Bool, optional, defaults to False_ — whether to modify
                `$container` in-place

_returns:_

* Container (original container is unmodified unless `:in-place` flag
  is passed)

_example:_

```perl6
my %h;
my @patch =
    { :op<add>, :path['a'], :value({:b({:c<here>})}) },
    { :op<add>, :path(qw<a b d>), :value([]) },
    { :op<add>, :path(|qw<a b d>, 0), :value<diamond> },
    { :op<replace>, :path(|qw<a b d>, *-1), :value<dangerous> },
    { :op<remove>, :path(qw<a b c>) },
    { :op<move>, :from(qw<a b d>), :path['d'] },
    { :op<copy>, :from(qw<a b>), :path['b'] },
    { :op<remove>, :path(qw<a b>) },
    { :op<replace>, :path['a'], :value(['alligators']) },
    { :op<replace>, :path['b'], :value(['be']) };
my %i = Crane.patch(%h, @patch);
```

Exception: `42 !== 'C'`

```perl6
my %h = :a({:b({:c})});
my @patch =
    { :op<replace>, :path(qw<a b c>), :value(42) },
    { :op<test>, :path(qw<a b c>), :value<C> };
my %i = Crane.patch(%h, @patch); # ✗ Crane error: patch operation failed, test failed
```

<!-- end .patch($container,@patch,:$in-place) }}} -->

-------------------------------------------------------------------------------

<!-- end methods }}} -->


<!-- classes {{{ -->

## Classes

<!-- classes toc {{{ -->

- [`Crane` Class](#crane-class)

<!-- end classes toc }}} -->

<!-- Crane Class {{{ -->

### `Crane` Class

Encapsulates container related operations for a specified path.

<!-- Crane Class attributes {{{ -->

#### attributes:

* `.path` : _Path_ — contains the `Crane`'s list of steps for navigating
            container

<!-- end Crane Class attributes }}} -->

<!-- Crane Class methods {{{ -->

#### methods:

<!-- .new(@path) {{{ -->

##### `.new(@path)`

Instantiates `Crane` class.

_arguments:_

* `@path` : _Path, required_ — a list of steps for navigating container

_returns:_

* a new `Crane` instance

_example:_

```perl6
my $crane = Crane.new('legumes', 0);
```

<!-- end .new(@path) }}} -->

`Crane` classes get access to all methods documented above, with
the stipulation that the path to the source container is the `Crane`
instance's `.path` attribute.

<!-- end Crane Class methods }}} -->

<!-- end Crane Class }}} -->

-------------------------------------------------------------------------------

<!-- end classes }}} -->


<!-- licensing {{{ -->

## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.

<!-- licensing }}} -->

<!-- vim: ft=markdown fdm=marker fdl=0 -->
