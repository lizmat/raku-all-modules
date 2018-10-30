#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Clean;

# A class that needs to close or free resources
class Foo does Cleanable {

  # Guaranteed to be called once the anonymous block finishes execution
  method clean {
    # Close or free resources here
  }
}

clean(
  # The object we need to be cleaned up
  Foo.new,

  # The anonymous block
  -> $obj {
    # Do stuff with $obj of type Foo
  }
);
