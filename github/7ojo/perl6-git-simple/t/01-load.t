use v6;
use lib 'lib';
use Test;

plan 2;

use-ok 'Git::Simple', 'load Git::Simple';
use-ok 'Git::Simple::Parse', 'load Git::Simple::Parse';
