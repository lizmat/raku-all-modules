use v6.c;


use Linux::Fuser::Procinfo;

=begin pod

=begin NAME

Linux::Fuser - Determine which processes have a file open

=end NAME

=begin SYNOPSIS

=begin code

  use Linux::Fuser;

  my $fuser = Linux::Fuser->new();

  my @procs = $fuser.fuser('foo');

  for @procs -> $proc ( @procs ) {
    say $proc.pid(),"\t", $proc.user(),"\n",$proc->cmd();
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

class Linux::Fuser:ver<0.0.9>:auth<github:jonathanstowe> {
    # Shamelessly stolen from IO::Path::More
    # for my own stability
    my role IO::Helper {
        use nqp;

        has Int $.inode;
        method inode() {
            if not $!inode.defined {
                if self.e {
                    $!inode = nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_INODE));
                }
            }
            $!inode;
        }

        has Int $.device;

        method device() {
            if not $!device.defined {
                if self.e {
                    $!device = nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_DEV));
                }
            }
            $!device;
        }

        method append (*@nextpaths) {
            my $lastpath = @nextpaths.pop // '';
            self.new($.SPEC.join($.volume, $.SPEC.catdir($.dirname, $.basename, @nextpaths), $lastpath));
        }

    }

    #| Given the path to a file as a String returns a list of L<doc:Linux::Fuser::Procinfo>
    #| objects describing any processes that have the file open
    multi method fuser (Str $file ) returns Array {
        self.fuser(IO::Path.new($file));
    }

    #| Given the L<doc:IO::Path> that describes the filereturns a list of L<doc:Linux::Fuser::Procinfo>
    #| objects describing any processes that have the file open
    multi method fuser(IO::Path $file ) returns Array {
        $file does IO::Helper;
        my @procinfo;
        my $device = $file.device;
        my $inode  = $file.inode;

        for dir('/proc', test => /^\d+$/) -> $proc-file {
            $proc-file does IO::Helper;
            my $fd_dir = $proc-file.append('fd');
            if $fd_dir.r {
                for $fd_dir.dir(test => /^\d+$/) -> $fd-file {
                    $fd-file does IO::Helper;
                    if ( self!same_file($file, $fd-file ) ) {
                        @procinfo.push(Linux::Fuser::Procinfo.new(:$proc-file, :$fd-file));
                    }
                }
            }
        }
        @procinfo;
    }

    method !same_file(IO::Path $left, IO::Path $right) {
        my Bool $rc = False;
        if ( ( $left.inode && ($left.inode == $right.inode) ) && ( $left.device == $right.device )) {
            $rc = True;
        }
        return $rc;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
