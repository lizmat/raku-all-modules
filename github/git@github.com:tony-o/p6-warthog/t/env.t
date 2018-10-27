#!/usr/bin/env perl6

use lib 'lib';

use Test;
use System::Query;

plan 1;

%*ENV<this_exists> = 'foo';
%*ENV<value_one> = 'one';

my $meta = {
    exists => {
        'by-env-exists.this_exists' => {
            'yes' => 1,
            'no'  => 0,
        }
    },
    doesnt_exist => {
        'by-env-exists.this_doesnt_exist' => {
            'yes' => 1,
            'no'  => 0,
        }
    },
    value_one => {
        'by-env.value_one' => {
            'one'  => 1,
            'zero' => 0,
        }
    },
};


is-deeply(
    system-collapse($meta),
    ${exists => 1, doesnt_exist => 0, value_one => 1}
);
