use v6;
use Test;

use Proc::More :ALL;

use File::Temp;

plan 13;

my $debug = 0;
my $time;

# tests 1-4
dies-ok { time-command 'fooie'; }
dies-ok { time-command 'fooie', :dir($*TMPDIR); }
lives-ok { $time = time-command 'ls -l', :dir($*TMPDIR); }
say "DEBUG: \$time = '$time'" if $debug;
cmp-ok $time, '>=', 0;

# tests 5-8
lives-ok { $time = time-command 'ls -l'; }
cmp-ok $time, '>=', 0;
lives-ok { $time = time-command 'ls -l', :dir($*TMPDIR); }
cmp-ok $time, '>=', 0;

# run some real commands with errors
# get a prog with known output
my $prog = q:to/HERE/;
$*ERR.print: 'stderr';
$*OUT.print: 'stdout';
HERE

my ($prog-file, $fh) = tempfile;
$fh.print: $prog;
$fh.close;

my $cmd = "perl6 $prog-file";

# run tests in the local dir
# tests 9-10
lives-ok { $time = time-command $cmd; }
cmp-ok $time, '>', 0;

# run tests in the tmp dir
my $f = "prog-file";
my $fh2 = open "$*TMPDIR/$f", :w;
$fh2.print: $prog;
$fh2.close;

# tests 11-12
$cmd = "perl6 $f";
lives-ok { $time = time-command $cmd, :dir($*TMPDIR); }
say "DEBUG: \$time = '$time'" if $debug;
cmp-ok $time, '>', 0;

# one more test
# test 13
dies-ok { time-command "cd $*TMPDIR; fooie"; }
