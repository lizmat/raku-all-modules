#!perl6

use v6;

use Test;

use Log::Syslog::Native;

ok my $obj = Log::Syslog::Native.new, "create new Log::Syslog::Native";

isa-ok($obj, Log::Syslog::Native, "the object is the right type");
is $obj.option, Log::Syslog::Native::Pid +| Log::Syslog::Native::ODelay, "option has the right default";
is $obj.facility, Log::Syslog::Native::Local0, "facility has the right default";

my @levs = (
Log::Syslog::Native::Alert,
Log::Syslog::Native::Critical,
Log::Syslog::Native::Error,
Log::Syslog::Native::Warning,
Log::Syslog::Native::Notice,
Log::Syslog::Native::Info,
Log::Syslog::Native::Debug
);

for @levs -> $lev {
   lives-ok { $obj.log($lev, "[TEST] with " ~ $lev.key) }, "log() with " ~ $lev.key;
   my $meth = $lev.key.lc;

   ok $obj.can($meth), " can do $meth";
   lives-ok { $obj."$meth"("[TEST] - test $meth method") }, "$meth method";
}

done();
