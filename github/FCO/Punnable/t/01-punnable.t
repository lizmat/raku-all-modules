use Test;

plan 4;

use lib "lib";
use Punnable;
role R1 {
	method r {...}
}

my $or1;
dies-ok {$or1 = R1.new};

role R2 {
	method r {...}
}

make-punnable(R2);

my $or2;
lives-ok {$or2 = R2.new};
does-ok $or2, R2;
dies-ok {$or2.r};
