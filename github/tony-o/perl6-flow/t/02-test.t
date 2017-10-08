use Flow::App;
use Test;

plan 3;

my Flow::App $x .=new;

$x.test-dir(qw<./t/dir1 ./t/dir2 ./t/dir3>);


$x.wait;

'---------------'.say;
my $result = $x.results.grep({ .<data>.so }).first<data>;

ok $result.passed == 2 && $result.failed == 0, 'TAP: 2 passed, 0 failed';
ok $result.problems.elems == 0, 'No problems parsing';
ok $result.noks.elems == 0, 'No not-ok tests';

