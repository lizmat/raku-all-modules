use v6.c;
use LibraryMake;
use NativeCall;

=begin pod

=begin NAME

Sys::Utmp - access to Utmp entries on Unix-like system

=end NAME

=begin SYNOPSIS

=begin code

    use Sys::Utmp;

    my $u = Sys::Utmp.new;

    for $u.list.grep(UserProcess) -> $ent {
        say $ent;
    }

=end code

=end SYNOPSIS

=begin DESCRIPTION

Sys::Utmp provides access to the Unix user accounting data that may be
described in the utmp(5) manpage.  Briefly it records each logged in
user (and some other data regarding the OS lifetime.)

It will prefer to use the getutent() function from the system C library
if it is available but will attempt to provide its own if the OS doesn't
have that. Because the implementation of getutent() differs between
various OS and the C part of this module needs to provide a consistent
interface to Perl it may not represent all the data that is available on
a particular system, similarly there may be documented attributes that
are not captured on some OS.

=end DESCRIPTION

=begin METHODS

=head2 method getutent

This returns the successive L<Sys::Utmp::Utent|#Sys::Utmp::Utent> each time
it is called until it has exhausted the records when it will return an
undefined object.

=head2 method setutent

This will reset the file pointer maintained by C<getutent> to the begining
so the file can be read again.

=head2 method endutent

This closes the utmp file and free any resources acquired by C<getutent>

=head2 method utmpname

Set the file to be read to something other than the default, this should
not be necessary but some systems may place the file in a non-standard
location.

=head2 method list

This will return the list of L<Sys::Utmp::Utent|#Sys::Utmp::Utent> 
objects that would be obtained if C<getutent> was called repeatedly but
is somewhat lazy if all the records aren't required.

=end METHODS

=head1 Sys::Utmp::Utent


=head2  user

Returns the use this record was created for if this is a record for a user
process.  Some systems may return other information depending on the record
type.  If no user was set this will be the empty string. 

=head2  id

The identifier for this record - it might be the inittab tag or some other
system dependent value.

=head2 line

For user process records this will be the name of the terminalor line that the
user is connected on.

=head2  pid

The process ID of the process that created this record.

=head2 type

The type of the record this will have a value corresponding to one of the
constants (not all of these may be available on all systems and there may
well be others which should be described in the getutent manpage or in
/usr/include/utmp.h ) :

The enum C<UtmpType> defines the constants as:

=item Accounting - record was created for system accounting purposes.

=item BootTime - the record was created at boot time.

=item DeadProcess - The process that created this record has terminated.

=item EmptyRecord  - record probably contains no other useful information.

=item InitProcess - this is a record for process created by init.

=item LoginProcess - this record was created for a login process (e.g. getty).

=item NewTime  - record created when the system time has been set.

=item OldTime - record recording the old tme when the system time has been set.

=item RunLevel - records the time at which the current run level was started.

=item UserProcess - record created for a user process (e.g. a login )

An object of L<Sys::Utmp::Utemp> can be smart matched to this values to
select for items of a certain type.

=head2 host

On systems which support this the method will return the hostname of the 
host for which the process that created the record was started - for example
for a telnet login.  

=head2 tv

The time in epoch seconds wt which the record was created.

=head2 timestamp

This returns a L<DateTime> that corresponds to C<tv>

=end pod

class Sys::Utmp:ver<0.0.10>:auth<github:jonathanstowe> {

    enum UtmpType is export <EmptyRecord RunLevel BootTime NewTime OldTime InitProcess LoginProcess UserProcess DeadProcess Accounting>;

    class Utent is repr('CStruct') {
        has int8 $.type;
        has int32 $.pid;
        has Str $.line;
        has Str $.id;
        has Str $.user;
        has Str $.host;
        has int $.tv;

        method timestamp() {
            DateTime.new($!tv // 0 );
        }

        method gist() {
            $!user ~ "\t" ~ $!line ~ "\t" ~ $.timestamp;
        }

        method Numeric() {
            $!type;
        }

        multi method ACCEPTS(Utent:D: UtmpType $type) {
            $!type == $type;
        }
    }

    my constant HELPER = %?RESOURCES<libraries/utmphelper>.Str;

    sub library {
        my $lib = 'libraries/' ~ $*VM.platform-library-name('utmphelper'.IO).Str;
        %?RESOURCES{$lib}.Str;
    }

    my sub _p_setutent() is native(HELPER) { * }

    method setutent() {
        _p_setutent();
    }

    my sub _p_endutent() is native(HELPER) { * }

    method endutent() {
        _p_endutent()
    }

    my sub _p_utmpname(Str) is native(HELPER) { * }

    method utpname(Str $utname ) {
        my $n = $utname;
        explicitly-manage($n);
        _p_utmpname($n);
    }

    my sub _p_getutent() returns Utent is native(HELPER) { * }

    method getutent() returns Utent {
        _p_getutent();
    }

    method list() {
        gather {
            loop {
                if self.getutent -> $utent {
                    take $utent;
                }
                else {
                    last;
                }
            }
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
