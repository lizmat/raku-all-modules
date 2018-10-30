use v6;

use Test;
use lib 'lib';
use App::Whiff;

plan 3;

is find-first(["tabasko", "cat"]), "/bin/cat", '/bin/cat is found.';
is find-first([]), False, 'empty path returns False';
is find-first(["non-existent-binary-file", "and-one-another"]), False, 'list of non-existent binaries returns False';
