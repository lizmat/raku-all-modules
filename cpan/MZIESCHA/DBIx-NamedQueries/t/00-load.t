use v6.c;

use lib 'lib';

use Test;

plan 4;

use-ok 'DBIx::NamedQueries';

use-ok 'DBIx::NamedQueries::Handles';
use-ok 'DBIx::NamedQueries::Handle::DBIish';

use-ok 'DBIx::NamedQueries::Plugins';
