use v6;
use Test;

plan 1;

BEGIN { @*INC.unshift( 'lib' ) }

use-ok("HTML::Restrict");
