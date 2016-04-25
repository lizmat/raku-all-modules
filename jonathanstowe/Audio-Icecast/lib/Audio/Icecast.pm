use v6.c;

=begin pod

=head1 NAME

Audio::Icecast - adminstrative interface to icecast

=head1 SYNOPSIS

=begin code

use Audio::Icecast;

# Using the default configuration

my $icecast = Audio::Icecast.new;

for $icecast.stats.source -> $source {
    say "listeners for { $source.mount }";
    for $icecast.listeners($source) -> $listener {
        say "\t",$listener.ip;
    }
}

=end code

See also the the C<example> directory.

=head1 DESCRIPTION

This provides an interface to the admin API of a running 
L<icecast|http://www.icecast.org> audio streaming server.

The API itself is quite thin as the icecast server doesn't
do much more than stream audio from a source quite efficiently.

Some features such as static mounts and alternative authentication
mechanisms can only be enabled via the configuration file and
not dynamically, if you want more control over the streams at
runtime then you might consider using a streaming middleware
such as L<liquidsoap|http://liquidsoap.fm/> in conjunction with
your icecast server.

You probably should at least familiarise yourself with the
L<icecast docummentation|http://www.icecast.org/docs/icecast-2.4.1/>
before making serious use of this module.

=head1 METHODS

Where given as a string below a mount name must be given as found in the
C<mount> attribute of L<Audio::Icecast::Source|#Audio::Icecast::Source>,
that is prefixed with a '/' (e.g. '/mount'.)

=head2 method new

    method new(Str :$host = 'localhost', Int :$port = 8000, Bool :$secure = False, Str :$user = 'admin', Str :$password = 'hackme')

The constructor for the class supplies defaults that will work with a
stock configuration on the local machine, this probably isn't what you
want, because at the very least you changed the password right? If you
are unsure of the appropriate values then you may need to look at the
C<icecast.xml> which will typically be in C</etc> or C</usr/local/etc>.

The C<:secure> flag is provided to allow an https connection to the
server but I am not actually aware of any possible configuration of
icecast which make this necessary.

=head2 method stats

    method stats() returns Stats

This returns a L<Audio::Icecast::Stats|#Audio::Icecast::Stats> object
that reflects the current statistics for the icecast server.

=head2 method listeners

    multi method listeners(Source $source)
    multi method listeners(Str $mount)

This returns a list of
L<Audio::Icecast::Listener|#Audio::Icecast::Listener>
objects reflecting the listeners of the supplied
mount, which can be supplied as either a string or a
L<Audio::Icecast::Source|#Audio::Icecast::Source> object.

=head2 method update-metadata

    multi method update-metadata(Source $source, Str $meta)
    multi method update-metadata(Str $mount, Str $meta)

This updates the stream metadata for the supplied mount which can either
be supplied as a L<Audio::Icecast::Source|#Audio::Icecast::Source>
object or a string.

=head2 method set-fallback

    multi method set-fallback(Source $source, Source $fallback)
    multi method set-fallback(Str $mount, Str $fallback)

This sets a fallback on the specified mount to another mount,
that is if the source for the mount disconnects then the
clients will be moved automatically to the fallback mount.
The source and fallback can be supplied as strings or
L<Audio::Icecast::Source|#Audio::Icecast::Source> objects.

=head2 method move-clients

    multi method move-clients(Source $source, Source $destination)
    multi method move-clients(Str $mount, Str $destination)

This will move the clients connected to the supplied mount
to a different one, which must have an active source. Both
source and destination can be supplied as strings or  as
L<Audio::Icecast::Source|#Audio::Icecast::Source> objects.

=head2 method kill-client

    multi method kill-client(Source $source, Listener $client)
    multi method kill-client(Str $mount, Str() $id)

This disconnects the client which can either be specified as a
L<Audio::Icecast::Listener|#Audio::Icecast::Listener> object or a string
ID, on the supplied mount.

=head2 method kill-source

    multi method kill-source(Source $source)
    multi method kill-source(Str $mount)

This disconnects the source client supplying the specified mount,
the mount can be supplied as the string name of the mount or as a
L<Audio::Icecast::Source|#Audio::Icecast::Source> object.

=head1 Audio::Icecast::Stats

Objects of this type represent the statistics for the running
icecast server, some of the attributes are derived directly
from the configuration file of the server and won't change.

=head2 mount

This is the name of the "mount", it will always be prefixed with
a '/', this is the local part of the URL on which listeners will
be able to connect to the resulting stream.

=head2 audio-info

This is a string describing the properties of the stream, 
comprised of C<bitrate>, C<channels> and C<samplerate>

=head2 bitrate

The streaming bitrate of the stream in Kilobits per second.

=head2 channels

The number of audio channels in the stream, this should only
over be 1 or two.

=head2 genre

The text genre as supplied by the source client.

=head2 listener-peak

The maximum number of concurrent listeners of the stream since
it was started.

=head2 listeners

The current number of connected listeners.

=head2 listen-url

This is the public URL of the stream, derived from the configured
host name of the server and the mount name.

=head2 max-listeners

This is the maximum permitted number of concurrent listeners
allowed on the stream, if it is "unlimited" it will be a very
big number (beyond the capability of icecast to serve.)

=head2 public

A boolean indicating whether the stream should be shown in a
directory of streams.  This is typically supplied by the
source client.

=head2 samplerate

This is the samplerate derived from the source stream.  It
is expressed in "frames per second", e.g. 44100

=head2 server-description

A description of the stream which will typically be supplied
by the source client.

=head2 server-name

The "name" of the stream which will typically be supplied
by the source client.

=head2 server-type

The media type of the stream as inferred from the source
stream, e.g. "audio/mpeg", "audio/aac".

=head2 slow-listeners

The number of listeners on the stream that are determined
to be "slow", that is to say they are being sent data that
is more than a single buffer behind what the source has 
sent. This may have an impact when the stream is shut down
or the client moved to another mount.

=head2 source-ip

This is the peer address of the source client.

=head2 stream-start

This is the datetime at which the source started, usually
the point when the source client connected, however it
may be different for a "static" mount defined in the
icecast config.

=head2 total-bytes-read

The total number of bytes received from the source client.

=head2 total-bytes-sent

The total number of bytes sent to the listeners of this
mount.

=head2 user-agent

The User-Agent header provided by the source client.

=head1 Audio::Icecast::Listener

This describes a consumer of a stream.

=head2 id

This is icecast's internal identifier for the client connection.
It is the value required by C<kill-client>. 

=head2 ip

The peer address of the client.

=head2 user-agent

The "User-Agent" header presented by the client software.

=head2 connected

A Duration object representing the number of seconds the client
has been connected.

=end pod


use XML::Class;
use HTTP::UserAgent;
use URI::Template;

class Audio::Icecast {
    class Source does XML::Class[xml-element => 'source'] {
        has Str $.mount;
        has Str $.audio-info is xml-element('audio_info');
        has Int $.bitrate is xml-element;
        has Int $.channels is xml-element;
        has Str $.genre is xml-element;
        has Int $.listener-peak is xml-element('listener_peak');
        has Int $.listeners is xml-element;
        has Str $.listen-url is xml-element('listenurl');
        sub ml-in(Str $v) returns Int {
            if $v eq 'unlimited' {
                int.Range.max;
            }
            else {
                Int($v);
            }
        }
        has Int  $.max-listeners is xml-deserialise(&ml-in) is xml-element('max_listeners');
        has Bool $.public is xml-element;
        has Int  $.samplerate is xml-element;
        has Str  $.server-description is xml-element('server_description');
        has Str  $.server-name is xml-element('server_name');
        has Str  $.server-type is xml-element('server_type');
        has Int  $.slow-listeners is xml-element('slow_listeners');
        has Str  $.source-ip is xml-element('source_ip');
        # TODO : find or fix something to parse the data format
        has Str  $.stream-start is xml-element('stream_start');
        has Int  $.total-bytes-read is xml-element('total_bytes_read');
        has Int  $.total-bytes-sent is xml-element('total_bytes_sent');
        has Str  $.user-agent is xml-element('user_agent');
    }
    class Stats does XML::Class[xml-element => 'icestats'] {
        has Str $.admin-email is xml-element('admin');
        has Int $.clients is xml-element;
        has Int $.connections is xml-element;
        has Int $.file-connections is xml-element('file_connections');
        has Str $.host is xml-element;
        has Int $.listener-connections is xml-element('listener_connections');
        has Int $.listeners is xml-element;
        has Str $.location is xml-element;
        has Str $.server-id is xml-element('server_id');
        # TODO: find or fix something to parse this format
        has Str $.server-start is xml-element('server_start');
        has Int $.source-client-connections is xml-element('source_client_connections');
        has Int $.source-relay-connections is xml-element('source_relay_connections');
        has Int $.source-total-connections is xml-element('source_total_connections');
        has Int $.sources is xml-element;
        has Int $.stats is xml-element;
        has Int $.stats-connections is xml-element('stats_connections');
        has Source @.source;
    }

    class Listener does XML::Class[xml-element => 'listener'] {
        has Str      $.ip           is xml-element('IP');
        has Str      $.user-agent   is xml-element('UserAgent');
        has Duration $.connected    is xml-element('Connected') is xml-deserialise(sub (Str $v --> Duration) { Duration.new($v) });
        has Str      $.id           is xml-element('ID');
    }
    class Listeners does XML::Class[xml-element => 'icestats'] {
        class Source does XML::Class[xml-element => 'source'] {
            has Str         $.mount;
            has Int         $.number-of-listeners   is xml-element('Listeners');
            has Listener    @.listeners;
        }
        has Source $.source is xml-element handles <listeners>;
    }

    class UserAgent is HTTP::UserAgent {
        use HTTP::Request::Common;
        role Response {
            method is-xml() returns Bool {
                if self.content-type eq 'text/xml' {
                    True;
                }
                else {
                    False;
                }

            }

            method from-xml(XML::Class:U $c) returns XML::Class {
                $c.from-xml(self.content);
            }

        }

        has Str             $.base-url;
        has URI::Template   $.base-template;

        has Bool            $.secure    =   False;
        has Str             $.host      =   'localhost';
        has Int             $.port      =   8000;
        has                 %.default-headers   = (Accept => "text/xml", Content-Type => "text/xml");

        method base-url() returns Str {
            if not $!base-url.defined {
                $!base-url = 'http' ~ ($!secure ?? 's' !! '') ~ '://' ~ $!host ~ ':' ~ $!port.Str ~ '{/path*}{?params*}';
            }
            $!base-url;
        }

        method base-template() returns URI::Template handles <process> {
            if not $!base-template.defined {
                $!base-template = URI::Template.new(template => self.base-url);
            }
            $!base-template;
        }

        method get(:$path, :$params, *%headers) returns Response {
            self.request(GET(self.process(:$path, :$params), |%!default-headers, |%headers)) but Response;
        }
    }

    submethod BUILD(Str :$host = 'localhost', Int :$port = 8000, Bool :$secure = False, Str :$user = 'admin', Str :$password = 'hackme') {
        $!ua = UserAgent.new(:$host, :$port, :$secure);
        $!ua.auth($user, $password);
    }

    has UserAgent $.ua handles <get>;

    method stats() returns Stats {
        my $resp = self.get(path => <admin stats>);
        if $resp.is-success {
            $resp.from-xml(Stats);
        }
    }

    proto method listeners(|c) { * }

    multi method listeners(Source $source) {
        samewith $source.mount;
    }

    multi method listeners(Str $mount) {
        my $resp = self.get(path => <admin listclients>, params => %(:$mount));
        if $resp.is-success {
            my $l = $resp.from-xml(Listeners);
            $l.listeners; 
        }
    }

    proto method update-metadata(|c) { * }

    multi method update-metadata(Source $source, Str $meta) {
        samewith $source.mount, $meta;
    }

    multi method update-metadata(Str $mount, Str $song) {
        my $resp = self.get(path => <admin metadata>, params => %(:$mount, :$song, mode => 'updinfo'));
        if $resp.is-success {
            True;
        }
        else {
            False;
        }
    }

    proto method set-fallback(|c) { * }

    multi method set-fallback(Source $source, Source $fallback) {
        samewith $source.mount, $fallback.mount;
    }

    multi method set-fallback(Str $mount, Str $fallback) {
        my $resp = self.get(path => <admin fallbacks>, params => %(:$mount, :$fallback));
        if $resp.is-success {
            True;
        }
        else {
            False;
        }
    }

    proto method move-clients(|c) { * }

    multi method move-clients(Source $source, Source $destination) {
        samewith $source.mount, $destination.mount;
    }

    multi method move-clients(Str $mount, Str $destination) {
        my $resp = self.get(path => <admin moveclients>, params => %(:$mount, :$destination));
        if $resp.is-success {
            True;
        }
        else {
            False;
        }
    }

    proto method kill-client(|c) { * }

    multi method kill-client(Source $source, Listener $client) {
        samewith $source.mount, $client.id;
    }

    multi method kill-client(Str $mount, Str() $id) {
        my $resp = self.get(path => <admin killclient>, params => %(:$mount, :$id));
        if $resp.is-success {
            True;
        }
        else {
            False;
        }
    }

    proto method kill-source(|c) { * }

    multi method kill-source(Source $source) {
        samewith $source.mount;
    }

    multi method kill-source(Str $mount) {
        my $resp = self.get(path => <admin killsource>, params => %(:$mount));
        if $resp.is-success {
            True;
        }
        else {
            False;
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
