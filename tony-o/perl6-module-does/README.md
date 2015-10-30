#Module::Does

[![Build Status](https://travis-ci.org/tony-o/perl6-module-does.svg)](https://travis-ci.org/tony-o/perl6-module-does)

This module is built for module authors that want to allow the module's audience to 'hot swap' modules with minimal code on their end.  This module gathers specified types from the `GLOBAL` scope upon object creation and then makes them available to the module.

#Usage

```perl6
use Module::Does;

class A does Module::Does[HTTP::Server] {
  method listen {
    $.server = %!base-types<HTTP::Server>.new(:$.localhost, :$.localport, :listen);
  }
}
```

##IDGI.

When `A` is instantiated, the private variable `%!base-types` is populated with anything in the global scope that `does HTTP::Server`.  

##Yea, but I want extra sauce, bro.

I got you.

```perl6
use Module::Does;

class A does Module::Does[@(HTTP::Server => HTTP::Server::Async, CSV::Parser)] {
# ...
}
```

If a `Pair` is passed in, then the `.key` is sought in the global scope and only if nothing is found, then `.value` is used.

Notice in the second value that an array is given, this module lets you pass in multiple types to look for and can consist of `class|Str|Pair`.


