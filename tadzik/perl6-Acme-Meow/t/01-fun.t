use v6;
use Test;

plan 6;

use Acme::Meow;

my $c = Acme::Meow.new;
ok $c.can('feed'), 'We can feed the cat';
ok $c.can('pet'), 'We can pet the cat';

lives-ok { $c.feed }, 'feeding works';
lives-ok { $c.feed('nip') }, 'feeding nip works';
lives-ok { $c.feed('milk') }, 'feeding milk works';
lives-ok { $c.pet  }, 'petting works';

done;
