use v6;

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

class Linux::Fuser::Procinfo:ver<v0.0.4>:auth<github:jonathanstowe> {
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
   has IO::Path $.proc_file;
   #| The L<doc:IO::Path> that corresponds to the /proc/<pid>/fd entry for the file
   has IO::Path $.fd_file;

   
   submethod BUILD(:$!proc_file, :$!fd_file) {
      $!pid = $!proc_file.basename + 0;
      my $cmdline = $!proc_file.append('cmdline').Str;
      # rather awkward locution but basically cmdline is a copy of the argv
      # as got to execve with the \0s and everything
      my $cmd_fh = open($cmdline, :bin);
      @!cmd = $cmd_fh.read(4096).decode.split("\0");
      $!filedes = Linux::Fuser::FileDescriptor.new(proc_file => $!proc_file, fd_file => $!fd_file);

      if ((my $uid = self!lstat_uid()).defined )
      {
         $!user = get_user_by_uid($uid).username;
      }

   }

   #| supply the required missing part of lstat() to get the owner of the FD
   method !lstat_uid() {
      nqp::p6box_i(nqp::stat(nqp::unbox_s($!fd_file.Str), nqp::const::STAT_UID));
   }

}
# vim: expandtab shiftwidth=4 ft=perl6
