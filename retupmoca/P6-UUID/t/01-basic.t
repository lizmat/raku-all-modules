use v6;
use Test;

plan 1;

use UUID;

my $u = UUID.new(:version(4));
ok $u, "Created version 4 (random) uuid"
