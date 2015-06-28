use v6;
use LibraryMake;
use NativeCall;


=begin pod

=head1 NAME

Sys::Lastlog - Provide a moderately Object Oriented Interface to lastlog 
               files on some Unix-like systems.

=head1 SYNOPSIS

=begin code

  use Sys::Lastlog;

  my $ll = Sys::Lastlog.new();

  while(my $llent = $ll.getllent() )
  {
    say $llent.ll_line;
  }

=end code

See also the C<bin/p6lastlog> in the distributed files.

=head1 DESCRIPTION

The lastlog file provided on most Unix-like systems stores information about
when each user on the system last logged in.  The file is sequential and
indexed on the UID (that is to say a user with UID 500 will have the 500th
record in the file).  Most systems do not provide a C API to access this
file and programs such as 'lastlog' will provide their own methods of doing
this.

This module provides an Object Oriented Perl API to access this file in order
that programs like 'lastlog' can written in Perl (for example the 'plastlog'
program in this distribution) or that programs can determine a users last
login for their own purposes.

The module provides three methods for accessing lastlog sequentially,
by UID or by login name.  Each method returns an object of
either type L<Sys::Lastlog::Entry|#Sys::Lastlog::Entry> or
L<Sys::Lastlog::UserEntry|#Sys::Lastlog::UserEntry>.

 that itself provides methods for accessing the information for each record.


=head2 METHODS


=head3 new

The constructor of the class.  Returns a blessed object that the other methods
can be called on.

=head3 getllent

This method will sequentially return each record in the lastlog each
time it is called, returning an undefined value when there are no
more records to return.  Because the lastlog file is indexed on UID
if there are gaps in the allocation of UIDs on a system will there
will be as many empty records returned ( that is to say if for some
reason there are no UIDs used between 200 and 500 this method will
nonetheless return the 299 empty records .)  This returns an object of
type L<Sys::Lastlog::UserEntry|#Sys::Lastlog::UserEntry>

=head3 getlluid( Int  $uid )

This method will return a record for the $uid specified or an undefined
value if the UID is out of range, it does however perform no check
that the UID has actually been assigned it must simply be less than or
equal to the maximum UID currently assigned on the system. Returns a
L<Sys::Lastlog::Entry|#Sys::Lastlog::Entry>

=head3 list

This will return a list of
L<Sys::Lastlog::UserEntry|#Sys::Lastlog::UserEntry> objects representing
every user defined in the system. They will be returned in order of
ascending C<uid> (which may differ from that output by the C<lastlog>
command on your system which may have them in the order they were added.)

Currently this is fairly inefficient as it will read each record of the
C<lastlog> file even if there is no corresponding user.

=head3 getllnam( Str $logname)

This will return the record corresponding to the user name C<$logname>
or an undefined value if it is not a valid user name.  Returns a
L<Sys::Lastlog::Entry|#Sys::Lastlog::Entry>

=head3 setllent

Set the file pointer on the lastlog file back to the beginning of the file
for repeated iteration over the file using getllent() .

=head2 Sys::Lastlog::Entry

These are the methods of the class L<Sys::Lastlog::Entry> that give access to
the information for each record in the C<lastlog> file.


=head3 time

The time in epoch seconds of this users last login. Or 0 if the user has
never logged in.

=head3 timestamp

The L<DateTime> corresponding to C<time>

=head3 has-logged-in

This returns a L<Bool> to indicate whether the user has ever logged in.

=head3 line

The line (e.g. terminal ) that this user logged in via.

=head3 host

The host from which this user logged in from or the empty string if it was
a local login.

=head2 Sys::Lastlog::UserEntry

Objects of this type are returned by the methods L<list|#list> and
L<getllent|#getllent>.  They will stringify to a format similar to the
output of a line from the command C<lastlog> on my system. 

It contains the user details so that the methods can be used in a
self-contained manner without having to look up the user details.

=head3 entry

This is the L<Sys::Lastlog::Entry|#Sys::Lastlog::Entry> describing the
record for the user.

=head3 user

This is the L<System::Passwd::User> object that describes the user that the
record is for.

=end pod

class Sys::Lastlog:ver<v0.0.2>:auth<github:jonathanstowe> {

    use System::Passwd;

    class Entry is repr('CStruct') {
        has int $.time;
        has Str $.line;
        has Str $.host;

        method timestamp() returns DateTime {
            DateTime.new($!time // 0 );
        }

        method has-logged-in() returns Bool {
            $!time.defined && ($!time != 0);
        }
    }

    class UserEntry {
        has Sys::Lastlog::Entry $.entry;
        has System::Passwd::User $.user;

        method gist() {
            my Str $latest;

            if $!entry.has-logged-in {
                $latest = $!entry.timestamp.Str;
            }
            else {
                $latest = '**Never logged in**';
            }
            sprintf self.r-format, $!user.username, $!entry.line, $!entry.host, $latest;
        }

        method r-format() {
            "%-26s%-10s%-16s%-25s";
        }
    }


    sub library {
        my $so = get-vars('')<SO>;
        my $libname = "lastloghelper$so";
        my $base = "lib/Sys/Lastlog/$libname";
        for @*INC <-> $v {
            if $v ~~ Str {
                $v ~~ s/^.*\#//;
                if ($v ~ '/' ~ $libname).IO.r {
                    return $v ~ '/' ~ $libname;
                }
            }
            else {
                if my @files = ($v.files($base) || $v.files("blib/$base")) {
                    my $files = @files[0]<files>;
                    my $tmp = $files{$base} || $files{"blib/$base"};

                    $tmp.IO.copy($*SPEC.tmpdir ~ '/' ~ $libname);
                    return $*SPEC.tmpdir ~ '/' ~ $libname;
                }
            }
        }
        die "Unable to find library";
    }

    my sub p_getllent()    returns Entry is native(&library) { * }

    method getllent() returns Entry {
        p_getllent();
    }

    method r-format() {
        UserEntry.r-format;
    }

    method list() {
        my Int $i = 0;
        gather {
            loop {
                if self.getllent() -> $entry {
                    if get_user_by_uid($i++) -> $user {
                        take UserEntry.new( entry => $entry, user => $user);
                    }
                }
                else {
                    last;
                }
            }
        }
    }
    
    my sub p_getlluid(Int) returns Entry is native(&library) { * }

    method getlluid(Int $uid --> Entry) {
        p_getlluid($uid);
    }

    my sub p_getllnam(Str) returns Entry is native(&library) { * }

    method getllnam(Str $logname --> Entry) {
        p_getllnam($logname);
    }

    my sub p_setllent() is native(&library) { * }

    method setllent() {
        p_setllent();
    }
}
