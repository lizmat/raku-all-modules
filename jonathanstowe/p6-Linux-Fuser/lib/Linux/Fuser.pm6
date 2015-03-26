
use lib 'lib';

use IO::Path::More;
use Linux::Fuser::Procinfo;

=begin pod

=begin NAME

Linux::Fuser - Determine which processes have a file open

=end NAME

=begin SYNOPSIS

=begin code
  use Linux::Fuser;

  my $fuser = Linux::Fuser->new();

  my @procs = $fuser->fuser('foo');

  for @procs -> $proc ( @procs )
  {
    say $proc->pid(),"\t", $proc->user(),"\n",$proc->cmd();
  }
=end code

=end SYNOPSIS

=begin DESCRIPTION

This module provides information similar to the Unix command 'fuser'
about which processes have a particular file open.  The way that this
works is highly unlikely to work on any other OS other than Linux and
even then it may not work on other than 2.2.* kernels. Some features
may not work correctly on kernel versions older than 2.6.22

It should also be borne in mind that this may not produce entirely
accurate results unless you are running the program as the Superuser
as the module will require access to files in /proc that may only be
readable by their owner.

=end DESCRIPTION

=begin METHODS

The class has one method, with two signatures, that does most of the work:

=end METHODS

=end pod

class Linux::Fuser {

   #| Given the path to a file as a String returns a list of L<doc:Linux::Fuser::Procinfo>
   #| objects describing any processes that have the file open
   multi method fuser (Str $file ) returns Array {
      self.fuser(IO::Path.new($file));
   }

   #| Given the L<doc:IO::Path> that describes the filereturns a list of L<doc:Linux::Fuser::Procinfo>
   #| objects describing any processes that have the file open
   multi method fuser (IO::Path $file ) returns Array {
      my @procinfo;

      my $device = $file.device;
      my $inode  = $file.inode;

      for dir('/proc', test => /^\d+$/) -> $proc {
         try {
            for $proc.append('fd').dir(test => /^\d+$/) -> $fd {
               if ( self!same_file($file, $fd ) ) {
                  @procinfo.push(Linux::Fuser::Procinfo.new(proc_file => $proc, fd_file => $fd));
                  CATCH {
                     note $_;
                  }
               }
            }
         }
      }
      return @procinfo;
   }

   method !same_file(IO::Path $left, IO::Path $right) {
      my Bool $rc = False;
      if ( ( $left.inode == $right.inode ) && ( $left.device == $right.device )) {
         $rc = True;
      }
      return $rc;
   }

}
