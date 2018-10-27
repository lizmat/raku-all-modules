use v6;
use lib 'lib';
use Test;
constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 


if AUTHOR { 
	require Test::META <&meta-ok>;
	meta-ok;
}
ok(True, 'Author test');
done-testing;
