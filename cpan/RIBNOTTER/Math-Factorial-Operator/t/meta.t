use v6;
use Test;
use lib 'lib';

plan 1;
#disable on users of the library so that they don't need Test::META
if False {
	use Test::META;
	meta-ok();
} else {
	skip 1;
}


