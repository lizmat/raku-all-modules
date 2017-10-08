use v6.c;

=begin pod

=head1 NAME

Monitor::Monit - Provide an interface to the monit monitoring daemon

=head1 SYNOPSIS

=begin code

use Monitor::Monit;

# use default settings
my $mon = Monitor::Monit.new;

for $mon.service -> $service {
	say $service.name, " is ", $sevice.status-name;
}

=end code

=head1 DESCRIPTION

Monit is a lightweight, relatively simple and widely used system
and application monitoring service.

This provides a mechanism to interact with its http api.


=head1 METHODS

=head2 method new

    method new(Str :$host = 'localhost', Int :$port = 2812, Str :$username = 'admin', Str :$password = 'monit', Bool :$secure = False);

The constructor for the class, the parameters provide sensible defaults
that should work out of the box for most installations.  By default the
C<monit> daemon will only listen for connections on the loopback network
device so if you intend to interact with a daemon on another C<host> you
may need to alter the configuration of the daemon.

If you are uncertain of the appropriate values for any of the parameters
you should check the configuration of the monit daemon or ask a
system administrator.


=head2 method status

    method status() returns Monitor::Monit::Status

This requests the entire status as reported by the daemon returning
a L<Monitor::Monit::Status|#Monitor::Monit::Status> object. This
conprises details of each monitored service, the platform that the
daemon is running on and the daemon itself.  For convenience these are
available as L<service|#method_service>, L<platform|#method_platform>
and L<server|#method_server> described below.

=head2 method service

    method service() returns Array[Monitor::Monit::Status::Service]

This returns a list of
L<Monitor::Monit::Status::Service|#Monitor::Monit::Status::Service>
describing each monitored service and their status.

=head2 method platform

    method platform() returns Monitor::Monit::Status::Platform

This returns a
L<Monitor::Monit::Status::Platform|#Monitor::Monit::Status::Platform>
object that describes the physical host that the daemon is running on.

=head2 method server

    method server() returns Monitor::Monit::Status::Server

This returns a
L<Monitor::Monit::Status::Server|#Monitor::Monit::Status::Server> object
that describes the parameters of the C<monit> daemon.

=head1 TYPES

=head2 Monitor::Monit::Status

=head3 attribute server

=head3 attribute platform

=head3 attribute service

=head2 Monitor::Monit::Status::Service

Provide the detail of a monitored service.

=head3 method command

    method command(Action $action) returns Bool 

Request the action specified by C<$action> on the service.
Returns a C<Bool> to indicate success or otherwise of the action.

The actions are specified by the C<enum> :

=item Stop

=item Start

=item Restart

=item Monitor

=item Unmonitor

For convenience each action is expressed as a method, described below.

=head3 method stop

    method stop() returns Bool

Stop the service if it is started.  This depends on there being a 
stop command configured in the configuration for the service.

=head3 method start

    method start() returns Bool

Start the service if it is stopped.  This depends on there being a 
start command configured in the configuration for the service.

=head3 method restart

    method restart() returns Bool

Restart the service, either by calling the configured restart command
or by calling the stop command followed by the start command. It may
fail if none of those are defined.

=head3 method monitor

    method monitor() returns Bool

Resume monitoring the service if it had been previously un-monitored.

=head3 method unmonitor

    method unmonitor() returns Bool

Turn off monitoring for the service (assuming it was being monitored.
This will turn off any alerts and auto restart that may be configured.

=head3 attribute type

=head3 attribute name

=head3 attribute collected

=head3 attribute collected-usec

=head3 attribute status

=head3 attribute status-hint

=head3 attribute monitor

=head3 attribute monitormode

=head3 attribute pendingaction

=head3 attribute pid

=head3 attribute ppid

=head3 attribute uid

=head3 attribute euid

=head3 attribute gid

=head3 attribute uptime

=head3 attribute children

=head3 attribute memory

=head3 attribute cpu

=head3 attribute port

=head3 attribute unix

=head3 attribute system

=head3 method status-name

    method status-name ( --> Str)


=head2 Monitor::Monit::Status::Platform

=head3 attribute name

The name of the operating system as reported. For example C<Linux>.

=head3 attribute version

The version of the operating system kernel as reported by C<uname>.

=head3 attribute machine

The architecture of the processor as would be reported by C<uname>.

=head3 attribute cpu

The number of CPU cores reported by the system.

=head3 attribute memory

The amount of memory in bytes.

=head3 attribute swap

The amount of swap space in bytes.

=head2 Monitor::Monit::Status::Server

This class represents the running monit instance.

=head3 attribute id

A unique identifier string for the C<monit> instance.

=head3 attribute incarnation

=head3 attribute version

A I<Version> object representing the running monit server.

=head3 attribute uptime

A I<Duration> object representing the time that the monit daemon has been
running.

=head3 attribute poll

A I<Duration> object representing the default time between the service 
checks.

=head3 attribute startdelay

A I<Duration> object representing delay between the program being started
and the first data being available.  It defaults to 0.0

=head3 attribute localhostname

The local hostname of the host the monit daemon is running on.  This is
likely to be unqualified.

=head3 attribute controlfile

The path to the control file for the monit instance.

=head3 attribute httpd

An Monitor::Monit::Status::Server::Httpd object representing the
http server that is used to communicate with the monit daemon. It has
the following attributes:

=head4 address

The IP address to which the http server is bound to, this may for instance
be '127.0.0.1' if it is only listening for local connections, '0.0.0.0'
if it is listening on all the interfaces, or a specific address.


=head4 port

The integer port number the server is listening on (and to which you are
connecting.)

=head4 ssl

A boolean to indicate whether it is an SSL connection.

=end pod


use HTTP::UserAgent;
use XML::Class;
use URI::Template;

class Monitor::Monit {

    has Str  $.host      =   'localhost';
    has Int  $.port      =   2812;
    has Bool $.secure    =   False;
    has Str  $.username  =   'admin';
    has Str  $.password  =   'monit';

    role MonitResponse {

    }

    class UserAgent is HTTP::UserAgent {
        use HTTP::Request::Common;

        has Str  $.host      =   'localhost';
        has Int  $.port      =   2812;
        has Bool $.secure    =   False;
        has Str  $.username  =   'admin';
        has Str  $.password  =   'monit';

        has %!default-headers;

        has Str $!base-url;


        method base-url() returns Str {
            if not $!base-url.defined {
                $!base-url = 'http' ~ ($!secure ?? 's' !! '') ~ '://' ~ $!host ~ ':' ~ $!port.Str ~ '{/path*}{?params*}';
            }
            $!base-url;
        }

        has URI::Template $!base-template;

        method base-template() returns URI::Template handles <process> {
            if not $!base-template.defined {
                $!base-template = URI::Template.new(template => self.base-url);
            }
            $!base-template;
        }


        proto method get(|c) { * }

        multi method get(:$path!, :$params, *%headers) returns MonitResponse {
            self.request(GET(self.process(:$path, :$params), |%!default-headers, |%headers)) but MonitResponse;
        }

        proto method post(|c) { * }

        multi method post(:$path!, :$params, Str :$content, :%form, *%headers) returns MonitResponse {
            if %form {
                # Need to force this here
                my %h = Content-Type => 'application/x-www-form-urlencoded', content-type => 'application/x-www-form-urlencoded';
                self.request(POST(self.process(:$path, :$params), %form, |%!default-headers, |%headers, |%h)) but MonitResponse;
            }
            else {
                self.request(POST(self.process(:$path, :$params), :$content, |%!default-headers, |%headers)) but MonitResponse;
            }
        }

    }

    has UserAgent $.ua;

    method ua() returns UserAgent handles <get put post> {
        if not $!ua.defined {
            $!ua = UserAgent.new(:$!host, :$!port, :$!secure, :$!username, :$!password);
            $!ua.auth($!username, $!password);
        }
        $!ua;
    }

    enum ServiceType <Filesystem Directory File Process Host System Fifo State>;

    class Status does XML::Class[xml-element => 'monit'] {
        sub duration-in(Str $v) returns Duration {
            $v.defined ?? Duration.new(Int($v)) !! Duration;
        }
        sub version-in(Str $v) returns Version {
            Version.new($v);
        }
        class Server does XML::Class[xml-element => 'server'] {
            class Httpd does XML::Class[xml-element => 'httpd'] {
                has Str $.address is xml-element;
                has Int $.port    is xml-element;
                has Bool $.ssl    is xml-element;
            }
            has Str         $.id            is xml-element;
            has Int         $.incarnation   is xml-element;
            has Version     $.version       is xml-element  is xml-deserialise(&version-in);
            has Duration    $.uptime        is xml-element  is xml-deserialise(&duration-in);
            has Duration    $.poll          is xml-element  is xml-deserialise(&duration-in);
            has Duration    $.startdelay    is xml-element  is xml-deserialise(&duration-in);
            has Str         $.localhostname is xml-element;
            has Str         $.controlfile   is xml-element;
            has Httpd       $.httpd;
        }
        class Platform does XML::Class[xml-element => 'platform'] {
            has Str     $.name  is xml-element;
            has Str     $.version   is  xml-element;
            has Str     $.machine   is  xml-element;
            has Int     $.cpu       is  xml-element;
            has Int     $.memory    is  xml-element;
            has Int     $.swap      is  xml-element;
        }

        class Service does XML::Class[xml-element => 'service'] {

            my @status-names = ("Accessible", "Accessible", "Accessible", "Running", "Online with all services", "Running", "Accessible", "Status ok", "UP");

            # TODO: Calculate the correct "failed" string from status-hint
            method status-name() returns Str {
                self.status == 0 ?? @status-names[self.type] !! 'Failed';
            }

            class Memory does XML::Class[xml-element => 'memory'] {
                has Num $.percent           is xml-element;
                has Num $.percent-total     is xml-element('percenttotal');
                has Int $.kilobyte          is xml-element;
                has Int $.kilobyte-total    is xml-element('kilobytetotal');
            }
            class Cpu does XML::Class[xml-element => 'cpu'] {
                has Num $.percent           is xml-element;
                has Num $.percent-total     is xml-element('percenttotal');
            }
            class Port does XML::Class[xml-element => 'port'] {
                has Str $.hostname          is xml-element;
                has Int $.portnumber        is xml-element;
                has Str $.request           is xml-element;
                has Str $.protocol          is xml-element;
                has Str $.type              is xml-element;
                has Num $.response-time     is xml-element('responsetime');
            }
            class Unix does XML::Class[xml-element => 'unix'] {
                has Str $.path              is xml-element;
                has Str $.protocol          is xml-element;
                has Num $.response-time     is xml-element('responsetime');
            }
            class System does XML::Class[xml-element => 'system'] {
                class Load does XML::Class[xml-element => 'load'] {
                    has Num $.average-minute    is xml-element('avg01');
                    has Num $.average-five      is xml-element('avg05');
                    has Num $.average-fifteen   is xml-element('avg15');
                }
                class Cpu does XML::Class[xml-element => 'cpu'] {
                    has Num $.user              is xml-element;
                    has Num $.system            is xml-element;
                    has Num $.wait              is xml-element;
                }
                class Memory does XML::Class[xml-element => 'memory'] {
                    has Num $.percent           is xml-element;
                    has Int $.kilobyte          is xml-element;
                }
                class Swap does XML::Class[xml-element => 'swap'] {
                    has Num $.percent           is xml-element;
                    has Int $.kilobyte          is xml-element;
                }
                has Load    $.load;
                has Cpu     $.cpu;
                has Memory  $.memory;
                has Swap    $.swap;
            }
            has ServiceType $.type              is xml-deserialise(-> Str $v { ServiceType($v) });
            has Str         $.name              is xml-element;
            has DateTime    $.collected         is xml-element('collected_sec') is xml-deserialise(-> Int(Str) $v { DateTime.new($v) } );
            has Int         $.collected-usec    is xml-element('collected_usec');
            has Int         $.status            is xml-element; 
            has Int         $.status-hint       is xml-element('status_hint');
            has Bool        $.monitor           is xml-element;
            has Int         $.monitormode       is xml-element;
            has Int         $.pendingaction     is xml-element;
            has Int         $.pid               is xml-element;
            has Int         $.ppid              is xml-element;
            has Int         $.uid               is xml-element;
            has Int         $.euid              is xml-element;
            has Int         $.gid               is xml-element;
            has Duration    $.uptime            is xml-element is xml-deserialise(&duration-in);
            has Int         $.children          is xml-element;
            has Memory      $.memory;
            has Cpu         $.cpu;
            has Port        @.port;
            has Unix        @.unix;
            has System      $.system;
        }

        has Server      $.server;
        has Platform    $.platform;
        has Service     @.service;

    }

    enum Action ( Stop => 'stop', Start => 'start', Restart => 'restart', Monitor => 'monitor', Unmonitor => 'unmonitor');

    class X::Monit::HTTP is Exception {
        has $.code is required;
        has $.status-line is required;

        method message() {
            "HTTP request failed : { $!code } {$!status-line}";
        }
    }

    role ServiceWrapper[UserAgent $ua] {
        has UserAgent $!ua handles <get put post> = $ua;

        method command(Action $action) returns Bool {
            my Bool $rc = False;
            my %form = action => $action.Str;
            if my $resp = self.post(path => [ self.name ], :%form  ) {
                $rc = $resp.is-success;
            }
            $rc;
        }

        method stop() {
            self.command(Stop);
        }
        method start() {
            self.command(Start);
        }
        method restart() {
            self.command(Restart);
        }
        method monitor() {
            self.command(Monitor);
        }
        method unmonitor() {
            self.command(Unmonitor);
        }
    }


    method status() returns Status handles <service platform server> {
        my Status $status;

        if my $resp = self.get(path => ['_status'], params => format => 'xml') {
            if $resp.is-success {
                $status = Status.from-xml($resp.content);
                $= $_ does ServiceWrapper[$!ua] for $status.service;
            }
            else {
                X::HTTP.new(code => $resp.code, status-line => $resp.status-line).throw;
            }
        }
        $status;
    }


}
# vim: expandtab shiftwidth=4 ft=perl6
