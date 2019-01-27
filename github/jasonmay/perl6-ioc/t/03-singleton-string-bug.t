use v6.c;
use lib 'lib';

use IoC;
use Test;
plan 2;

my $c = container 'mycont' => contains {
    service 'constructor-injection' => {
        type => Str,
    };

    service 'block-injection' => {
        'block' => sub {
            return 1
        },
    };
};

lives-ok { $c.resolve('constructor-injection') }, 'constructor-injection without singleton';
lives-ok { $c.resolve('block-injection') }, 'block-injection without singleton';

done-testing;
