use v6;
use Test;

constant package-name = 'Chemistry::Elements';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

can-ok $class, 'min_Z';
can-ok $class, 'max_Z';

is $class.min_Z,   1, 'Min Z is 1';
is $class.max_Z, 118, 'Max Z is 118';

done-testing;
