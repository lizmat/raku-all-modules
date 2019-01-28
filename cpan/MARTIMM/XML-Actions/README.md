# XML Actions on every node

[![Build Status](https://travis-ci.org/MARTIMM/XmlActions.svg?branch=master)](https://travis-ci.org/MARTIMM/XmlActions) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/6yaqqq9lgbq6nqot?svg=true&branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending)](https://ci.appveyor.com/project/MARTIMM/XmlActions/branch/master) [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

## Synopsis
```
use Test;
use XML::Actions;

my Str $file = "a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <scxml xmlns="http://www.w3.org/2005/07/scxml"
         version="1.0"
         initial="hello">

    <final id="hello">
      <onentry>
        <log expr="'hello world'" />
      </onentry>
    </final>
  </scxml>
  EOXML


class A is XML::Actions::Work {
  method final ( Array $parent-path, :$id ) {
    is $id, 'hello', "final called: id = $id";
    is $parent-path[*-1].name, 'final', 'this node is final';
    is $parent-path[*-2].name, 'scxml', 'parent node is scxml';

  method log ( Array $parent-path, :$expr ) {
    is $expr, "'hello world'", "log called: expr = $expr";
    is-deeply @$parent-path.map(*.name), <scxml final onentry log>,
              "<scxml final onentry log> found in parent array";
  }
}

my XML::Actions $a .= new(:$file);
isa-ok $a, XML::Actions, 'type ok';
$a.process(:actions(A.new()));

```
Result would be like
```
ok 1 - type ok
ok 2 - final called: id = hello
ok 3 - this node is final
ok 4 - parent node is scxml
ok 5 - log called: expr = 'hello world'
ok 6 - <scxml final onentry log> found in parent array
```

## Documentation

Users who wish to process XML::Elements must provide an instantiated class which inherits from XML::Actions::Work. In that class, methods named after the elements can be defined. The `$parent-path` is an array holding the XML::Elements of the parent elements with the root on the first position and the current element on the last. The attributes are found on the XML element.
```
class A is XML::Actions::Work {

  method someElement ( Array $parent-path, :$someAttribute ... ) {...}
  method someOtherElement ( Array $parent-path, :$someAttribute ... ) {...}
}
```

There are also text-, comment-, cdata- and pi-nodes. They can be defined as
```
  ...
  method PROCESS-TEXT ( Array $parent-path, Str $text ) {...}
  method PROCESS-COMMENT ( Array $parent-path, Str $comment ) {...}
  method PROCESS-CDATA ( Array $parent-path, Str $cdata ) {...}
  method PROCESS-PI ( Array $parent-path, Str $pi-target, Str $pi-content ) {...}
  ...
```
If you want to process an element after all children are processed, you can use the same element method with `-END` attached. It has the same number arguments.
  ```
  method someElement-END ( Array $parent-path, :$someAttribute ... ) {...}
  ```

### Changes
One can find the changes document [in ./doc][release]

## Installing

Use zef to install the package: `zef install XML::Actions`

## Versions of PERL, MOARVM

This project is tested against the newest perl6 version with Rakudo built on MoarVM implementing Perl v6.

## AUTHORS

Current maintainer **Marcel Timmerman** (MARTIMM on github)

## License

**Artistic-2.0**

<!---- [refs] ----------------------------------------------------------------->
[release]: https://github.com/MARTIMM/XmlActions/blob/master/doc/CHANGES.md
