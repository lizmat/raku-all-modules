# Text::Table::List

## Introduction

A library to build simple text-based tables for use on a command line
interface. We're using Unicode box drawing characters by default, so please
ensure your terminal supports them. If not, never fear, you can use the
Text::Table::List::ASCII varient which uses standard ASCII characters, or
define your own set of characters entirely.

## Usage

Currently we only support a very minimal table-like structure, here is one
example:

```perl
my $t1 = Text::Table::List.new(:length(40)).start;
$t1.label("A Test Table");
$t1.line;
$t1.field("Hello:", "World");
$t1.field("Goodbye:", "Universe");
$t1.line;
$t1.label("And now for some numbers.");
$t1.blank;
$t1.field("Pi:", pi.base(16));
$t1.field("The Answer:", 42);
$t1.field("Nonsense:", "31.34892");
```

The above would output something that looks like:

```

  ╔══════════════════════════════════════╗
  ║ A Test Table                         ║
  ╟──────────────────────────────────────╢
  ║ Hello:                         World ║
  ║ Goodbye:                    Universe ║
  ╟──────────────────────────────────────╢
  ║ And now for some numbers.            ║
  ║                                      ║
  ║ Pi:                         3.243F6A ║
  ║ The Answer:                       42 ║
  ║ Nonsense:                   31.34892 ║
  ╚══════════════════════════════════════╝

```

You can also pass multiple named paramters to the field() method and each
one will be used as a name/value pair.

For more, see the tests and examples, in the 't' and 'example' folders 
respectively.

## Future

This module is pretty simple, and supports only a very small subset of
the functionality expected from a table. The most obvious is that it does
not support any form of real columns. It has separator lines, blank lines,
labels and fields (which consist of a name and a value.) That's it.

So, for a future project, I'd like to build another Text::Table::* module
that allows you to build text-based tables with full column support.

It will be it's own project, as I want to keep this one as simple as possible.

## Author

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

