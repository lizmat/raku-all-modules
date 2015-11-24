use v6;
use Test;
plan 14;
use Acme::Flutterby;

my $butterfly = Flutterby.new();
isa-ok($butterfly,'Flutterby');
ok(Flutterby.^can('foodage'), "Flutterby can eat");
ok(Flutterby.^can('happiness'), "Flutterby can be happy");
ok(Flutterby.^can('tired'), "Flutterby can be sleepy");
my @attributes = Flutterby.^attributes();

ok(@attributes.elems == 3,"Has only 3 attributes");
ok(Flutterby.^can('feed'), "You can feed me");
ok(Flutterby.^can('play'), "You can play with me");
ok(Flutterby.^can('nap'), "You can give me a nap");
ok(Flutterby.^can('sacrifice'), "You can sacrifice me ");

isnt($butterfly.tired,True,"I am rested ");
$butterfly.feed;ok($butterfly.foodage==1,"I have been fed");

ok($butterfly.happiness==1,"I am a little happy");
$butterfly.play;
ok($butterfly.happiness==3,"I am a little happer");
$butterfly.play;
$butterfly.play;
$butterfly.play;
$butterfly.play;
$butterfly.play;
isnt($butterfly.tired,False,"I am tired ");
