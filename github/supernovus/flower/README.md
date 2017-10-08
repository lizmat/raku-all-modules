# Flower: XML Application Languages

## Introduction

Flower is a library for building and using XML Application Languages.
An XML Application Language can be anything that takes an XML document,
and parses it using a set of data. It's perfect for creating template engines,
custom XML syntax, and much more, all using pure XML as its input and output
formats.

Flower was originally written to create an implementation of the TAL and METAL
template engines from Zope. Flower's name was originally a play on the Perl 5
Petal library. Since then, Flower has outgrown its original scope, bringing
in further ideas from Template::TAL, PHPTAL, and some of my own custom XML
concepts. The original TAL/METAL/TALES parsers are still included, and can
be easily used by using Flower::TAL, which is included (see below.)

## Flower::TAL

This is an easily loadable library that extends Flower and automatically
loads the Flower::TAL::TAL, Flower::TAL::METAL application languages
by default, and offers the ability to easily load plugins for the
Flower::TAL::TALES attribute parser (used by Flower::TAL::TAL)

### Differences from Petal (and Template::TAL, PHPTAL and Zope)

 * The default local namespace is 'tal', and to override it, you must
   declare http://xml.zope.org/namespaces/tal instead of the Petal namespace.
 * Flower can use template strings instead of requiring files.
 * In addition to strings, it can use a custom provider class.
   Currently a File provider is included.
 * Flower does not support the multiple template files based on language.
   But that can be added easily by defining a custom Provider class.
 * Adding custom modifiers is completely different in Flower.
 * There is NO support for anything but well-formed XML.
   There is no equivelant to the Petal::Parser::HTB, and no plans for one.
 * Flower supports tal:block elements, as per the PHPTAL project.
 * While you can use the 'structure' keyword, it's not really needed.
   If you want an unescaped XML structure for a replacement, send an
   Exemel object (any class other than Document) and it will be added to
   the XML tree. Send an array of Exemel objects, and they will additionally
   be parsed for TAL statements.
 * Nested repeats cannot use the same attribute name, it will get clobbered.
 * The built-in repeat object is implemented as per Zope and PHPTAL, not
   the Petal version. Note: it does not support the 'letter' or 'Letter' 
   attributes, but instead has some new methods that take paramters: 
     'every xx'   the number (not the index) is divisible by xx.
     'skip xx'    the number is not divisible by xx.
     'gt xx'      the number is greater than xx.
     'lt xx'      the number is less than xx.
     'eq xx'      the number is equal to xx.
     'ne xx'      the number is not equal to xx.
 * I'm not sure how Petal, PHPTAL or Zope deal with TAL attributes in the
   root element (the top-most element of the document), but to avoid death,
   destruction and mayhem, Flower only processes 'define', 'attributes'
   and 'content' tags on the root element. The rest of the tags are only
   processed on children of the root.

The above list will be updated as this project is developed, as I'm sure
other changes will be introduced that will be a gotchya for users of Petal,
Zope or PHPTAL.

### Flower::TAL::TALES Plugins

Inspired by Petal::Utils, Flower includes a bunch of libraries in the
Flower::TAL::TALES:: namespace. These are available using Flower::TAL's
add-tales() method.

  * Text, same as the :text set from Petal::Utils

    * lc:      make the string lowercase.
    * uc:      make the string uppercase.
    * ucfirst: make the first letter of the string uppercase.
    * substr:  extract a portion of the string.
    * printf:  format a string or object in a specified way.

  * List, similar to the :list set from Petal::Utils.

    * group:   turns a flat Array into a nested Array, where each inner 
               Array has a set number of elements in it.
    * sort:    sort the array using the default sort algorithm.
    * limit:   only return the first number of items from the list.
    * shuffle: shuffle the list into a random order.
    * pick:    pick a set number of items randomly from the list.
    * reverse: reverse the contents of the list.

  * Date, similar to the :date set from Petal::Utils, using on DateTime::Utils

    * date:     Builds a DateTime object using specified paramters.
    * time:     Builds a DateTime object from a Unix epoch.
    * strftime: Displays a date/time string in a specified format.
    * rfc:      A modifier specifically for use with strftime, as the format.
    * now:      A modifier specifically for use with strftime, as the object.

  * Debug, similar to :debug set from Petal::Utils.

    * dump: modifier spits out the .perl representation of the object.
    * what: modifier spits out the class name of the object.

In addition, the following sets are planned for inclusion at some point:

  * Logic, similar to the :logic set from Petal::Utils
  * Hash, same as the :hash set from Petal::Utils

The syntax for the Flower::TAL plugins is based on the modifiers from
Petal::Utils, but extended to use the Flower-specific extensions (the
same method that is used to parse method call parameters in queries.)
As is obvious, the syntax is not always the same, and not all of the
modifiers are the same.

Full documentation for the usage of Flower and the Flower::Utils modifiers
will be included in the doc/ folder in an upcoming release, until then
there are comments in the libraries, and test files in t/ that show the
proper usage.

The URI set from Petal::Utils is not planned for inclusion,
feel free to write it if you need it.
I'm sure new exciting libraries will be made adding onto these.

## TODO

 * Add Logic and Hash TALES plugins.
 * Implement optional query caching.
 * Implement multiple paths (/test/path1 | /test/path2) support.
 * Implement on-error.
 * Add Flower::Provider::Multiple for querying providers by prefix.

## Requirements

 * [XML](http://github.com/supernovus/exemel/)
 * [DateTime::Utils](http://github.com/supernovus/temporal-utils/)

## Author

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

