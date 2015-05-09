
use v6;

use NativeCall;

=begin pod

=begin NAME

Log::Syslog::Native - access to POSIX syslog facility

=end NAME 

=begin SYNOPSIS

=begin code

   use Log::Syslog::Native;

   my $logger = Log::Syslog::Native.new(facility => Log::Syslog::Native::Mail);

   $logger->warning("Couldn't activate wormhole interface");

=end code

=end SYNOPSIS

=begin DESCRIPTION

This provides a simple, perhaps naive,interface to the POSIX syslog
facility found on most Unix-like systems.

It should be enough to get you started with simple logging to your
system's log files, though exactly what files those might be and how
they are logged is a function of the system configuration and the exact
logging software that is being used.

This does not provide logging to a remote syslog server, nor does
it provide syslog style logging to platforms that do not provide a
C<syslog()> function in their standard runtime library.


=end DESCRIPTION

=begin METHODS

=end METHODS

There are provided a number of methods to post a log at a given priority.

All of these can take a C<sprintf> format and a list of values. The C<sprintf>
may throw an exception if a mismatch between format and supplied values is
detected or if there is an un-recognised C<%> format code in the format.


Whilst the POSIX C<syslog> function is documented to be able to accept a
format and a variadic list of values, this is currently emulated with Perl's
builtin C<sprintf> due to a native call limitation  so the acceptable format
string may differ from the system documentation.

The C<enum>s documented below will need to be used fully qualified with
C<Log::Syslog::Native::> from user code.

=head2 method new

    method new(Str :$ident, Int :$option, Facility :$facility)

The constructor for the object.  C<ident> will set the identity field
for the log messages and default to C<$*PROGRAM_NAME>.  C<option> is the
OR of log option enum values as described below, it defaults to C<Pid +|
ODelay> which for most purposes should not need changing.  C<facility>
is a value of the C<Facility> enum as described below, it defaults to
C<Local0> and setting it may, depending on the syslog configuration on
your system, alter how and where the messages are logged to.

=end pod

class Log::Syslog::Native {

=begin pod

=head2 enum LogLevel

These correspond to the log C<priority> and will typically be passed to the
C<log> method. The exact meaning of the priorites may depend on the 
system's logging configuration, but the descriptions come from the syslog.h.

=item Emergency 

System is unusable

=item Alert 

Action must be taken immediately

=item Critical 

Critical conditions

=item Error 

Error conditions

=item Warning 

Warning conditions

=item Notice 

Normal but significant condition

=item Info 

Informational

=item Debug

Debug-level messages

=end pod

    enum LogLevel <Emergency Alert Critical Error Warning Notice Info Debug>;

=begin pod

=head2 enum LogFacility

A value of this type may be supplied to the C<facility> argument of the
constructor, depending on the configuration of the logging system different
values may cause the message to be logged in a different manner. Clearly some
of these refer to actual facilities that may not even exist on a modern
system and may be repurposed if you have access to the configuration.

=item Kernel

Kernel messages

=item User

Random user-level messages

=item Mail

Mail system 

=item Daemon

System daemons

=item Auth

Security/authorization messages

=item Syslog

Messages generated internally by syslogd

=item Lpr

Line printer subsystem

=item News

Network news subsystem

=item Uucp

UUCP subsystem

=item Cron

Clock daemon

=item Authpriv

Security/authorization messages (private)

=item Ftp

FTP daemon

=item Local0

Reserved for local use 

=item Local1

Reserved for local use 

=item Local2

Reserved for local use

=item Local3

Reserved for local use

=item Local4

Reserved for local use

=item Local5

Reserved for local use

=item Local6

Reserved for local use

=item Local7

Reserved for local use

=end pod

    enum LogFacility (  
                        :Kernel( 0 +< 3),
                        :User( 1 +< 3),
                        :Mail( 2 +< 3),
                        :Daemon( 3 +< 3),
                        :Auth( 4 +< 3),
                        :Syslog( 5 +< 3),
                        :Lpr( 6 +< 3),
                        :News( 7 +< 3),
                        :Uucp( 8 +< 3),
                        :Cron( 9 +< 3),
                        :Authpriv( 10 +< 3),
                        :Ftp( 11 +< 3),
                        :Local0( 16 +< 3),
                        :Local1( 17 +< 3),
                        :Local2( 18 +< 3),
                        :Local3( 19 +< 3),
                        :Local4( 20 +< 3),
                        :Local5( 21 +< 3),
                        :Local6( 22 +< 3),
                        :Local7( 23 +< 3) );

=begin pod

=head2 enum LogOptions

A binary OR of these values can be passed to the C<option> argument of the
constructor, though a sensible set of defaults is provided.

=item Pid

Log the pid with each message

=item Console

Log on the console if errors in sending

=item ODelay

Delay open until first syslog() (default)

=item NDelay

Don't delay open

=item NoWait

Don't wait for console forks: DEPRECATED

=item Perror

Log to stderr as well

=end pod

    enum LogOptions (   
                        :Pid(0x01), 
                        :Console(0x02), 
                        :ODelay(0x04), 
                        :NDelay(0x08),
                        :NoWait(0x10),
                        :Perror(0x20));

    has Str $.ident    = $*PROGRAM_NAME;
    has Int $.option   = Pid +| ODelay;
    has Int $.facility = Local0;

    sub _syslog(Int, Str) is native is symbol('syslog') { ... }
    sub _openlog(Str, Int, Int) is native is symbol('openlog') { ... }
    sub _closelog() is native is symbol('closelog') { ... }

    submethod BUILD(:$!ident = $*PROGRAM_NAME, :$option?, :$facility) {
        $!option = $option // Pid +| ODelay;
        $!facility = $facility // Local0;
        my $i = $!ident;
        explicitly-manage($i);
        _openlog($i, $!option, $!facility);
    }

    #| log at priority C<Emergency>
    #| Depending on your syslog configuration this may output to all logged
    #| in terminals so should probably be used sparingly
    method emergency(Str $format, *@args) {
        self.log(Emergency, $format, @args);
    }

    #| log at priority C<Alert>
    method alert(Str $format, *@args) {
        self.log(Alert, $format, @args);
    }
    
    #| log at priority C<Critical>
    method critical(Str $format, *@args) {
        self.log(Critical, $format, @args);
    }

    #| log at priority C<Error>
    method error(Str $format, *@args) {
        self.log(Error, $format, @args);
    }
    
    #| log at priority C<Warning>
    method warning(Str $format, *@args) {
        self.log(Warning, $format, @args);
    }
    
    #| log at priority C<Notice>
    method notice(Str $format, *@args) {
        self.log(Notice, $format, @args);
    }

    #| log at priority C<Info>
    method info(Str $format, *@args) {
        self.log(Info, $format, @args);
    }
    
    #| log at priority C<Debug>
    method debug(Str $format, *@args) {
        self.log(Info, $format, @args);
    }

    #| log at given C<$priority>
    method log(LogLevel $priority, Str $format, *@args ) {
        my $mess = sprintf $format, @args;
        _syslog($priority.Int, $mess);

    }

    submethod DESTROY {
        _closelog();
    }
    
}
