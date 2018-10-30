use v6;

use lib 'lib';

use Test;

plan 2;

use File::Temp;
ok 1, "'use File::Temp' worked !";

use-ok 'File::Temp';
