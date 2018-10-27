use v6;

use lib 'lib';

use Test;

plan 1;

use Pod::To::BigPage;

my @files = find-pod-files( ".", <.git .precomp>, <pod6 pm6> );
cmp-ok +@files, ">=", 2, "Found files we wanted to find";
                             
