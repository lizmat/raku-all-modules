use v6;
use Test;
use lib 'lib';
plan 4;

use-ok 'Acme::Cow';

use Acme::Cow;
my $cow = Cow::cow.new;
ok $cow, "cow.new works";
lives-ok { $cow.set-face("stoned"); },"cow.set-face(\$face) works";
ok {?run 'cow-say','--about', :out}, "binary runs ok";
