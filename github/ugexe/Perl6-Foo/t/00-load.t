use v6;
use Test;
plan 2;

use-ok("Foo");
use-ok("Foo:ver<1.2>:auth<github:ugexe>");
