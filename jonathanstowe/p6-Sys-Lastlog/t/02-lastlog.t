#!perl6

use v6;


use Test;

plan 16;

use Sys::Lastlog;
use System::Passwd::User;

my $uid;
my $logname;

#diag try { qx/id/ };

if $*USER.defined {
   $uid = $*USER.Numeric;
   $logname = $*USER.Str;
}
else {
   $uid = 0;
   $logname = 'root';
   todo('$*USER is not defined for some reason', 16);
}

ok my $obj = Sys::Lastlog.new, "create a Sys::Lastlog object";

isa-ok $obj, Sys::Lastlog, "and it's the right sort of thing";

my $ret;

lives-ok { $ret = $obj.getlluid($uid) }, "getlluid()";

ok $ret.defined, "it's defined";

isa-ok $ret, Sys::Lastlog::Entry, "and that returns the right thing";

lives-ok { $ret = $obj.getllnam($logname) }, "getllnam()";

ok $ret.defined, "it's defined";

isa-ok $ret, Sys::Lastlog::Entry, "and that returns the right thing";


isa-ok $ret.timestamp(), DateTime, "timestamp is a DateTime";

todo "won't be logged in on CI platform", 1;
ok $ret.has-logged-in, "has-logged-in";


my @uents;

lives-ok { @uents = $obj.list }, "list()";

# this may of course not work on some weird system
isa-ok @uents[0], Sys::Lastlog::UserEntry, "first entry is right thing";
isa-ok @uents[0].user, System::Passwd::User, "the user attribute is right";
isa-ok @uents[0].entry, Sys::Lastlog::Entry, "and so is the entry";
is @uents[0].user.username, "root", "and it's for 'root'";
like @uents.gist, rx/^.root/, "and the gist is about right";

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
