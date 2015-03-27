use v6;
use strict;

=begin pod

=begin NAME

Linux::Fuser::FileDescriptor - describe a file opened by a process

=end NAME

=begin DESCRIPTION

This provides additional information about the file descriptor instance as 
opened by a process.  Typically it will be accessed via the C<fdinfo> attribute
of L<doc:Linux::Fuser::Procinfo> and need not be constructed in user code.

Because it needs to read the C</proc/<pid>/fdinfo/<fd>> entry which will only be
readable by the user that has the file open this may not work as expected unless
run by the superuser.

=end DESCRIPTION

=begin ATTRIBUTES

There are no public methods only attributes.

=end ATTRIBUTES

=end pod

class Linux::Fuser::FileDescriptor {

   #| The file descriptor number in use by the process
   has Int $.fd;
   #| The position in the file the opening process has the file pointer
   has Int $.pos;
   #| mnt_id
   has Int $.mnt_id;
   #| The flags with which the file was opened
   has Int $.flags;

   #| The L<doc:IO::Path> of the /proc entry as passed to the constructor
   has IO::Path $.proc_file;
   #| The L<doc:IO::Path> of the /proc/<pid>/fd entry as passed to the constructor
   has IO::Path $.fd_file;
   #| The L<doc:IO::Path> corresponding to the /proc/<pid>/fdinfo 
   has IO::Path $.fd_info;

   submethod BUILD(:$!proc_file, :$!fd_file) {
      $!fd = $!fd_file.basename.Int;
      $!fd_info = $!proc_file.append('fdinfo', $!fd);
      my %info = open($!fd_info.Str, :bin).read(255).decode.lines.map( { $_.split(/\:\t/) }).hash;
      $!pos = %info<pos>.Int;
      $!mnt_id = %info<mnt_id>.Int;
      my $str_fl = %info<flags>;
      $!flags = :8($str_fl);
   }
}
