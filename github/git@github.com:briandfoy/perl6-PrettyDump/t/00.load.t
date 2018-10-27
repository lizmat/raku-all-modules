use v6;
use PrettyDump;
use Test;

constant package-name = 'PrettyDump';

use-ok package-name or bail-out "{package-name} did not compile";

my $class = ::(package-name);
my $pretty = $class.new;
isa-ok $pretty, package-name;

done-testing();
