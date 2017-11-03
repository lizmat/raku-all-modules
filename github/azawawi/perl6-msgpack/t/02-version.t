

use v6;

use Test;
use MsgPack;

plan 6;

my $version = MsgPack::version;

diag $version.perl;
ok $version ~~ Hash, "Version is a four-element hash";
ok $version<major>    ~~ Int, "Major is an integer";
ok $version<minor>    ~~ Int, "Minor is an integer";
ok $version<revision> ~~ Int, "Revision is an integer";
ok $version<string>   ~~ Str, "Version is a string";
ok $version<string>   ~~ /\d+ '.' \d+ '.' \d+/, "Version matches x.y.z";
