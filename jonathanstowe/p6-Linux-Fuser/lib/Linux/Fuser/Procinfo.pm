use v6.c;

use nqp;
use Linux::Fuser::FileDescriptor;
# For the time being
use System::Passwd;

=begin pod

=begin NAME

Linux::Fuxer::Procinfo - describe the process that has a file opened.

=end NAME

=begin DESCRIPTION

An array of objects of this type are returned by the method C<fuser> in 
L<doc:Linux::Fuser>.  It describes a single process that has the requested
file open.

Because it has to read special files that may only be readable by the user that
owns the process it may not work as expected for users other than the superuser.

Typically objects of this type will be created as needed by C<fuser> and there
should be no need for user code to construct new objects.

=end DESCRIPTION

=begin ATTRIBUTES

There are no public methods only read-only attributes.

=end ATTRIBUTES

=end pod

class Linux::Fuser::Procinfo:ver<0.0.8>:auth<github:jonathanstowe> {
    #| The process ID of the process that has the file open
    has Int $.pid;
    #| The username of the user who owns the process
    has Str $.user;
    #| An array of the parts of the command that this process represents, i.e the argv
    #| as passed to the system execve()
    has Str @.cmd;
    #| A L<doc:Linux::Fuser::FileDescriptor> that describes the file as the process
    #| has it opened.
    has Linux::Fuser::FileDescriptor $.filedes;

    #| The L<doc:IO::Path> describing the /proc entry
    #| This is passed to the constructor
    has IO::Path $.proc-file;
    #| The L<doc:IO::Path> that corresponds to the /proc/<pid>/fd entry for the file
    has IO::Path $.fd-file;

   
    submethod BUILD(:$!proc-file, :$!fd-file) {
        $!pid = $!proc-file.basename + 0;
        my $cmdline = $!proc-file.append('cmdline');
        # rather awkward locution but basically cmdline is a copy of the argv
        # as got to execve with the \0s and everything
        my $cmd_fh = $cmdline.open(:bin);
        @!cmd = $cmd_fh.read(4096).decode.split("\0");
        $!filedes = Linux::Fuser::FileDescriptor.new(proc-file => $!proc-file, fd-file => $!fd-file);

        if ((my $uid = self!lstat_uid()).defined ) {
            $!user = get_user_by_uid($uid).username;
        }
    }

    #| supply the required missing part of lstat() to get the owner of the FD
    method !lstat_uid() {
        nqp::p6box_i(nqp::stat(nqp::unbox_s($!fd-file.Str), nqp::const::STAT_UID));
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
