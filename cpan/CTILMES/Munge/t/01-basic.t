use Test;
use Test::When <extended>;

use Munge;

plan 5;

ok my $m = Munge.new, 'new';

ok my $encoding = $m.encode, 'encode empty credential';

is $m.decode($encoding), '', 'decode empty credential';

ok $encoding = $m.encode('this'), 'encode string';

is $m.decode($encoding), 'this', 'decode string';

done-testing;
