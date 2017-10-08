use v6;

use Test;
use lib 'lib';

use Config::Netrc;

my Str $text = q:to/EOI/;
# this is my netrc
machine m
login l # cool login
password p # cool password

default
login default_login # default username
password default_password
EOI

ok parse($text) !~~ Nil;

$text = q:to/EOI/;
# only default
default
login ld
password pd
EOI

ok parse($text) !~~ Nil;


$text = q:to/EOI/;
machine m
login l
EOI

ok parse($text) !~~ Nil;

$text = q:to/EOI/;
machine m
login l # comment
password p # easy case
EOI

ok parse($text) !~~ Nil;

$text = q:to/EOI/;
machine m
password p # with only password
EOI

ok parse($text) !~~ Nil;

done-testing;
