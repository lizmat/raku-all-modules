#!perl6

use v6;

use Test;
use Shell::Command;

use XDG::BaseDirectory;

my $obj;

lives-ok { $obj = XDG::BaseDirectory.new }, " new XDG::BaseDirectory";

isa-ok($obj, XDG::BaseDirectory, "right sort of thing");

ok($obj.can(Q[data-home]), Q[can data-home]);
ok($obj.can(Q[data-dirs]), Q[can data-dirs]);
ok($obj.can(Q[config-home]), Q[can config-home]);
ok($obj.can(Q[config-dirs]), Q[can config-dirs]);
ok($obj.can(Q[cache-home]), Q[can cache-home]);
ok($obj.can(Q[save-config-path]), Q[can save-config-path]);
ok($obj.can(Q[save-data-path]), Q[can save-data-path]);
ok($obj.can(Q[load-config-paths]), Q[can load-config-paths]);
ok($obj.can(Q[load-first-config]), Q[can load-first-config]);
ok($obj.can(Q[load-data-paths]), Q[can load-data-paths]);
ok($obj.can(Q[runtime-dir]), Q[can runtime-dir]);

my $base = $*CWD.child('.test_' ~ $*PID);

$base.mkdir;

%*ENV<XDG_CONFIG_HOME> = $base.child('.config').Str;
%*ENV<XDG_DATA_HOME> = $base.child($*SPEC.catfile('.local', 'share')).Str;
%*ENV<XDG_CACHE_HOME> = $base.child('.cache').Str;

isa-ok $obj.cache-home, IO::Path, "cache-home";
isa-ok($obj.config-home, IO::Path, 'config-home is an IO::Path');
isa-ok($obj.data-home, IO::Path, 'data-home is an IO::Path');
is($obj.config-home.Str, $base.child('.config').Str, 'config-home is the right path');
is($obj.data-home.Str, $base.child($*SPEC.catfile('.local', 'share')).Str, 'data-home is the right path');
isa-ok($obj.runtime-dir, IO::Path, "runtime-dir is an IO::Path");
ok $obj.runtime-dir, "it's defined";
ok $obj.runtime-dir.d, "and it's a directory";

ok(my $scp = $obj.save-config-path('foo', 'bar'), 'save-config-path');
isa-ok($scp, IO::Path, 'and it is an IO::Path');
ok($scp.Str.IO.d, 'and the directory exists (directly from path)');
ok($scp.d, 'and the directory exists');

ok((my @cp = $obj.load-config-paths('foo','bar')), 'load-config-paths');
ok(@cp.elems, "got at least one element");
is(@cp[0].Str, $scp.Str, "and it is the one that we expected");

ok(my $sdp = $obj.save-data-path('foo', 'bar'), 'save-data-path');
isa-ok($sdp, IO::Path, 'and it is an IO::Path');
ok($sdp.Str.IO.d, 'and the directory exists (directly from path)');
ok($sdp.d, 'and the directory exists');

ok((my @dp = $obj.load-data-paths('foo','bar')), 'load-data-paths');
ok(@dp.elems, "got at least one element");
is(@dp[0].Str, $sdp.Str, "and it is the one that we expected");

throws-like { $obj.load-config-paths('..','..') }, X::InvalidResource, message => "invalid resource description", "throws with a '..' relative path";
throws-like { $obj.load-config-paths('/foo','/baz') }, X::InvalidResource,"throws with a resulting absolute path";


END {
   if $base.e {
      rm_rf($base);
   }
}



done-testing();
