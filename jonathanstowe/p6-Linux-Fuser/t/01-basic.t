use v6;

use Test;
use lib 'lib';

use Linux::Fuser;

my $obj;



ok(Linux::Fuser.^can('fuser'), "Linux::Fuser can 'fuser()'");

lives_ok { $obj = Linux::Fuser.new() }, "create a new Linux::Fuser";

isa_ok($obj,Linux::Fuser, "and it's the right kind of object");

my $filename = $*PID ~ '.tmp';

my $fh = open "$*PID.tmp", :w;

do_tests($filename, "with string filename");
do_tests($filename.IO, "with IO::Path");

sub do_tests(Any $file, Str $description)
{
   my @procs;

   lives_ok { @procs = $obj.fuser($file) }, "fuser() doesn't die ($description)";

   ok(@procs.elems, "got some processes ($description)");
   ok(my $proc = @procs[0], "get the first ($description)");

   isa_ok($proc,Linux::Fuser::Procinfo, "And it's the right kind of object ($description)");
   is($proc.pid, $*PID, "got the expected PID ($description)");
   ok($proc.cmd.elems, "got some command line ($description)");
   todo("not sure how to test this yet",1);
   is($proc.cmd[0], $*EXECUTABLE, "and got something like we expected");

   is($proc.user, my_username(), "got the right user ($description)");

   ok(my $filedes = $proc.filedes, "get the filedescriptor info ($description)");
   isa_ok($filedes,Linux::Fuser::FileDescriptor, "and it's the right sort of object ($description)");
   is($filedes.pos, 0, "pos is 0 ( $description )");
   ok($filedes.flags > 0, "flags is greater than 0 ($description)");
   ok($filedes.mnt_id.defined, "mnt_id is defined ( $description)");
}

$fh.close;

my @procs;

lives_ok { @procs = $obj.fuser($filename) }, "fuser() closed file";
is(@procs.elems,0, "and there aren't any processes");

lives_ok { @procs = $obj.fuser('ThiSdoesNotExIst') }, "fuser() no-existent file";
is(@procs.elems,0, "and there aren't any processes");

# because I can't work out how to do this otherwise
use NativeCall;
use System::Passwd;
sub getuid() returns Int is native { ... }

sub my_username() returns Str {
   return get_user_by_uid(getuid()).username;
}



$filename.IO.remove;

done;

