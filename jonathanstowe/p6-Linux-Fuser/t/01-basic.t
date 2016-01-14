use v6;

use Test;
use lib 'lib';

use Linux::Fuser;

my $obj;



ok(Linux::Fuser.^can('fuser'), "Linux::Fuser can 'fuser()'");

lives-ok { $obj = Linux::Fuser.new() }, "create a new Linux::Fuser";

isa-ok($obj,Linux::Fuser, "and it's the right kind of object");

my $filename = $*PID ~ '.tmp';


my $fh = open $filename, :w;

do_tests($filename, "with string filename");
do_tests($filename.IO, "with IO::Path");

sub do_tests(Any $file, Str $description)
{
   my @procs;

   lives-ok { @procs = $obj.fuser($file) }, "fuser() doesn't die ($description)";

   ok(@procs.elems, "got some processes ($description)");
   ok(my $proc = @procs[0], "get the first ($description)");

   isa-ok($proc,Linux::Fuser::Procinfo, "And it's the right kind of object ($description)");
   is($proc.pid, $*PID, "got the expected PID ($description)");
   ok($proc.cmd.elems, "got some command line ($description)");
   todo("not sure how to test this yet",1);
   like($proc.cmd[0], /{ $*VM.config<bindir> }/, "and got something like we expected");

   is($proc.user, $*USER, "got the right user ($description)");

   ok(my $filedes = $proc.filedes, "get the filedescriptor info ($description)");
   isa-ok($filedes,Linux::Fuser::FileDescriptor, "and it's the right sort of object ($description)");
   is($filedes.pos, 0, "pos is 0 ( $description )");
   ok($filedes.flags > 0, "flags is greater than 0 ($description)");
   ok($filedes.mnt_id.defined, "mnt_id is defined ( $description)");
}

$fh.close;

my @procs;

lives-ok { @procs = $obj.fuser($filename) }, "fuser() closed file";
is(@procs.elems,0, "and there aren't any processes");

lives-ok { @procs = $obj.fuser('ThiSdoesNotExIst') }, "fuser() no-existent file";
is(@procs.elems,0, "and there aren't any processes");


$filename.IO.unlink;

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
