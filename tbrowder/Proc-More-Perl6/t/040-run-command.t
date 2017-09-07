use v6;
use Test;

use Proc::More :ALL;

use File::Temp;

plan 21;

my ($exitcode, $stderr, $stdout);

# tests 1-7
dies-ok { $exitcode = run-command 'fooie'; die if $exitcode; }
cmp-ok $exitcode, '!=', 0;
dies-ok { $exitcode = run-command 'fooie', :dir($*TMPDIR); die if $exitcode; };
cmp-ok $exitcode, '!=', 0;
dies-ok { ($exitcode, $stderr, $stdout) = run-command 'fooie', :dir($*TMPDIR), :all; die if $exitcode; };
cmp-ok $exitcode, '!=', 0;
lives-ok { run-command 'ls -l', :dir($*TMPDIR), :all, :out, :err; }

# run some real commands with errors
# tests 8-13
lives-ok { run-command 'ls -l' }
lives-ok { run-command 'ls -l', :dir($*TMPDIR); }
lives-ok { run-command 'ls -l', :all; }
lives-ok { run-command 'ls -l', :dir($*TMPDIR), :all; }
lives-ok { run-command 'ls -l', :dir($*TMPDIR), :all, :out; }
lives-ok { run-command 'ls -l', :dir($*TMPDIR), :out; }

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
# tests 13-16
{
    ($exitcode, $stderr, $stdout) = run-command $cmd, :all;
    is $stderr, 'stderr';
    is $stdout, 'stdout';
    cmp-ok $exitcode, '==', 0;
}

# run tests in the tmp dir
# tests 17-19
{
    ($exitcode, $stderr, $stdout) = run-command $cmd, :all, :dir($*TMPDIR);
    is $stderr, 'stderr';
    is $stdout, 'stdout';
    cmp-ok $exitcode, '==', 0;
}

# two more tests
# tests 20-21
dies-ok { $exitcode = run-command "cd $*TMPDIR; fooie"; die if $exitcode; }
cmp-ok $exitcode, '!=', 0;
