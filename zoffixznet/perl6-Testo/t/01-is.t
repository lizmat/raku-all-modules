use lib <lib>;
use Testo;

plan 6;

is 1, 1;
is 1, none 2;
is 1, 1.0;
is 1, '1';
is 'foobar', /foo/;
is 'foobar', none /meow/;
