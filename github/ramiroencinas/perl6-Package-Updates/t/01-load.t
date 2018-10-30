use v6;
use lib 'lib';
use Test;

plan 2;

use Package::Updates;
ok 1, "use Package::Updates worked!";
use-ok 'Package::Updates';
