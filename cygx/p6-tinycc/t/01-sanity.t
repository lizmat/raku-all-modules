#!/usr/bin/env perl6

use v6;

use Test;
use TinyCC;

ok defined(tcc), 'TinyCC appears to have been loaded';
ok defined(tcc.state), 'TinyCC state is defined';
ok tcc.state != 0, 'TinyCC state is not NULL';

done;
