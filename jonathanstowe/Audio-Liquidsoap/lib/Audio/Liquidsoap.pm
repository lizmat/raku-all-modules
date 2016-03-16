use v6.c;

=begin pod

=head1 NAME

Audio::Liquidsoap - Interact with the Liquidsoap telnet interface.

=head1 SYNOPSIS

=begin code

use Audio::Liquidsoap;

my $ls = Audio::Liquidsoap.new;

say "Connected to liquidsoap { $ls.version } up since { DateTime.new($ls.uptime) }";


...

=end code

More expansive examples can be found in the examples directory

=head1 DESCRIPTION

This provides a mechanism to interact with the L<Liquidsoap media
toolkit|http://liquidsoap.fm/> and possibly build radio applications
with it.

It provides abstractions to interact with the defined Inputs, Outputs,
Queues, Playlists and Requests to the extent allowed by the "telnet"
interface of C<liquidsoap>.  There is also a generalised mechanism
for sending arbitrary commands to the server, such as those that may
have been provided by the liquidsoap C<server.register> function.
However it should be borne in mind that you will almost certainly need
to still actually to write some liquidsoap script in order to declare
the things to manipulate. 

=head2 Audio::Liquidsoap

    class Audio::Liquidsoap

This provides the primary interface for interacting with the liquidsoap
instance and will acquire and construct the details of all the other
objects as necessary.

=head3 method new

    method new(Int :$port = 1234, Str :$host = 'localhost', Client :$client)

This is the constructor of the class, the host and port of the liquidsoap
command interface can be provided and default to 1234 and 'localhost'. A
client object will be created as necessary but one can be provided if for
instance one is required with different capabilities (this allows for instance
for the future addition of a Unix socket interface.)

=head3 attribute client

This is the L<Audio::Liquidsoap::Client> that will be created as required. The
primary interface C<command> is delegated to this class, so you probably don't
need to worry about it unless you have special requirements.

=head3 attribute port

This is the port that the liquidsoap command interface is using, it will default
to the liquidsoap default of 1234 and will typically be set in the constructor.

=head3 attribute host

This  is the host that the liquidsoap command interface can be found on.  It
defaults to 'localhost'.  Typically however a liquidsoap instance will only
bind to the loopback interface for security reasons so it is unlikely that
you will need to change it.

=head3 method command

    method command (Str $command, *@args)

This sends the command C<$command> to liquidsoap command interface and returns
the response verbatim (except the output terminator) If the response indicates
there was an error an exception (L<X::Command>) will be thrown. Any additional
arguments given will be given to the command as-is (separated by spaces.)

This is actually a delegation from the C<client> but this should be the preferred
interface for running ad-hoc commands on the server (such as those added by
C<server.register>

=head3 method uptime

    method uptime ( --> Duration)

This returns a L<Duration> object indicating how long the liquidsoap instance has
been running.

=head3 method version

    method version ( --> Version)

This returns a L<Version> object that is based on the version string of the
liquidsoap.

=head3 method list

    method list ()

This returns a list of the lines returned by the C<list> command of the
liquidsoap. Internally it used to determine what objects are exposed
by the server and their types, but it may be useful for the purposes
of debugging or for dealing with things that aren't catered for.

=head3 method get-vars

    method get-vars ()

This returns a Hash keyed by name of the interactive variables defined
in the liquidsoap script, the values represent the type of the
liquidsoap variable (either Bool, Str or Numeric (which stands in for
the liquidsoap "float".

=head3 method get-var

    method get-var (Str $name)

This returns the value of the named variable (which should be one that
has been returned by C<get-vars>.) If the name does not exist then an
L<X::NoVar> will be thrown.

=head3 method set-var

    method set-var (Str $name, $val)

This sets the interactive variable specified by $name to $val. The
value should be of an appropriate type as returned by C<get-vars>.

If the variable named doesn't exist then a L<X::NoVar> will be thrown.

A boolean is returned to indicate whether the variable was set on
the server successfully.

=head3 method requests

    method requests ( --> Audio::Liquidsoap::Request)

This returns an L<Audio::Liquidsoap::Request> object that reflects
the state of all the requests for output on the liquidsoap from
any source (and is distinct from the 'requests' that might come
from a Queue for instance.)

=head3 method queues

    method queues ()

This returns a Hash keyed by name of L<Audio::Liquidsoap::Queue>
objects. Each one representing a "request.queue" defined in the
liquidsoap script.

=head3 method outputs

    method outputs ()

This returns a Hash keyed by name L<Audio::Liquidsoap::Output>
objects representing the outputs defined in the liquidsoap script.
An application may have various outputs to different streaming
servers or in different encodings for instance.

=head3 method inputs

    method inputs ()

This returns a Hash keyed by name of L<Audio::Liquidsoap::Input>
objects representing inputs defined in the liquidsoap script
(e.g. 'input.harbour', 'input.http',) because these may have
different behaviours the actual object may have a role applied
to represent the type.

=head3 method playlists

    method playlists ()

This returns a Hash keyed by name of L<Audio::Liquidsoap::Playlist>
objects. These objects represent the playlists defined by 'playlist()'
in the liquidsoap script. A typical radio application may use more
than one playlist to represent various schedule slots.

=head2 Audio::Liquidsoap::Queue

    class Audio::Liquidsoap::Queue does Audio::Liquidsoap::Item

Objects of this class represent 'request queues' declared with
'request.queue' or 'request.equeue' in the liquidsoap script.

The queue allows for the addition of arbitrary single tracks
by URI (which can either be a remote url or a local filename
which must be qualified to a path that is accessible to
liquidsoap.)

=head3 attribute name

The name of the queue.

=head3 attribute client

The L<Audio::Liquidsoap::Client> object that is common with all
the other objects.

=head3 method push

    method push (Str $uri --> Int)

Add a new track to the queue. The supplied URI must either by
a resolvable to url of a single remote file or a full local
filepath.  It will return the "request ID" of the queued
request or throw an L<X::Command> if there was an error.

=head3 method consider

    method consider ($rid)

In the first instance all new requests will be placed in the
secondary queue and will be moved to the primary queue and
thence become candidates to be sent to an output when necessary.

C<consider> will move the request specified by "request id" from
the secondary queue to the primary queue.

=head3 method ignore

    method ignore ($rid)

Ignoring a request specified by "request id" in the secondary queue
will stop that request being selected to be played. It may be removed
from the secondary queue at some point.

=head3 method queue

    method queue ()

This is a list of all the request ids of all the requests in the
queue. Comprising both the primary and secondary queues.

=head3 method primary-queue

    method primary-queue ()

The primary queue is where the selected tracks are chosen to become
sources that will be sent to the output(s).  This is a list of the
request ids.

=head3 method secondary-queue

    method secondary-queue ()

A list of the request ids that have not yet been selected for the
primary queue, they can be added to the primary queue with C<consider>
or C<ignored>

=head2 Audio::Liquidsoap::Output

    class Audio::Liquidsoap::Output does Audio::Liquidsoap::Item

This represents an output as defined in the liquidsoap script. There
may be multiple outputs defined for example for different streaming
servers, encodings or bitrates.  They can all be controlled individually.

=head3 attribute type

This is the type of the output which may be e.g. "icecast", "alsa" or
any other configured in the liquidsoap. 

=head3 attribute name

The name of the output.

=head3 attribute client

The L<Audio::Liquidsoap::Client> object.

=head3 method start

    method start ()

Start the output if it is not already started.

=head3 method stop

    method stop ()

Stop the output if it is started.

=head3 method status

    method status ()

This returns the status of the output, it may be "on" or "off".

=head3 method skip

    method skip ()

This causes the output to request its source to provide a new
request to be output (which may be an item from a playlist or
queue for instance.)  Some types of source may not actually
support skipping so it may not work for them.

=head3 method autostart

    method autostart ( --> Bool)

This is a boolean to indicate whether the output should automatically
start itself when a playable source becomes available, it is a read/write
method so can be set to control the behaviour.

=head3 method remaining

    method remaining ( --> Duration)

This returns a L<Duration> object representing the time remaining on the
current source (e.g. track from a playlist or queue.)

=head3 method metadata

    method metadata ()

This returns a list of all the L<Audio::Liquidsoap::Metadata> of the
individual tracks from all sources that are available to this output.


=head2 Audio::Liquidsoap::Request

    class Audio::Liquidsoap::Request does Audio::Liquidsoap::Item

This represents something of an aggregation of all the requests in
the system from the various queues, manually or dynamically created
requests and so forth.

=head3 attribute name

This is always 'request'

=head3 attribute client

The shared L<Audio::Liquidsoap::Client> object.

=head3 method alive

    method alive ()

This a list of the request ids of the requests that are able to be
sent to an output now, this may include the aggregate of all the
primary queues and any manually or dynamically created requests.

=head3 method all

    method all ()

A list of all the request ids on the system.

=head3 method on-air

    method on-air ()

This is a list of the "on air" request ids, depending on the way the
sources are defined there may actually be more than one entry in the
list despite there being only one output, you may need to calculate
, based on the source specified in the metadata which one is actually
playing.

=head3 method resolving

    method resolving ()

This is a list of the request ids of those request that have entered
the system but have not yet been completely 'resolved', if most of
the requests are for local files then this may generally be empty,
if there are remote files that need to copied then they may appear
here.

=head3 method trace

    method trace ($rid)

This returns a list of TraceItem objects for the specified request
id, there will be at least one, they have C<when> which is a L<DateTime>
when the event occurred and C<what> which is largely free text describing
what happened.  This can be useful for seeing what happens to requests.

=head3 method metadata

    method metadata ($rid --> Audio::Liquidsoap::Metadata)

This returns an L<Audio::Liquidsoap::Metadata> object for the specified
request ID.


=head2 Audio::Liquidsoap::Metadata

The metadata contains information that is derived from the source
(e.g. ID3 tags) and internally by liquidsoap.

=head3 attribute title

This will be the ID3 "title" tag if present.

=head3 attribute artist

This will be the ID3 "artist" tag if present.

=head3 attribute decoder

This is the internal name of the decoder that liquidsoap used for
the input data, e.g. "MAD" if it was MP3 data.

=head3 attribute filename

This is the filename that is being used by liquidsoap. If the
request URI was a local filename then this will be the same
as C<initial-uri>

=head3 attribute initial-uri

This is the uri that was used to originally make the request,
it may be the same as C<filename> if it represents a local file.

=head3 attribute kind

This is the subtype of the liquidsoap source in the form of
something like "{audio=2;video=0;midi=0}" , indicating the
number of channels of each key in the source.  It is not
very useful but it is used by liquidsoap to determine the
suitability of a request for a source or an outpur.

=head3 attribute on-air

A DateTime representing when the request went on-air, it
may be undefined if the request hasn't yet been on air.

=head3 attribute rid

The request ID.

=head3 attribute source

The id of the source as specified in the liquidsoap script,
this may be a request queue or playlist for instance.

=head3 attribute status

The text status of the request. e.g. "playing", "ready"

=head3 attribute temporary

A Bool indicating whether "filename" represents a temporary
file that willl be removed when the request is done with.

=head3 method new

    multi method new (:$metadata!)

The constructor can take a whole record of metadata as returned
by liquidsoap.

=head2 Audio::Liquidsoap::Input

    class Audio::Liquidsoap::Input does Audio::Liquidsoap::Item

This represents an input as defined in the liquidsoap script,
because the various input types have different capabilities the
objects as created for the C<inputs> hash will have a role applied
that will give them additional methods.

=head3 attribute type

This is the name of the type of the input e.g. "http", "harbor".

=head3 attribute name

The name of the input.

=head3 attribute client

The shared L<Audio::Liquidsoap::Client> object.

=head3 method buffer-length

    method buffer-length ()

The length of the buffer that is being used on the input.

=head3 method stop

    method stop ()

Stops the input, marking it as unavailable.

=head3 method status

    method status ( --> Str)

Returns the status of the input as a string. e.g. "stopped", may differ
from type to type.

=head2 Audio::Liquidsoap::Input::Http

    role Audio::Liquidsoap::Input::Http

This is applied to inputs of type 'http' it provides two additional
methods. It describes an input which retrieves its source from an
external stream over http (such as icecast)

=head3 method start

    method start ( --> Bool)

Attempts to start this input returning a Bool to indicate success or otherwise.

=head3 method uri

    method uri ( --> Str)

This is a read/write method that can be used to get or set the uri that the
input is being retrieved from. 

=head2 Audio::Liquidsoap::Input::Harbor

    role Audio::Liquidsoap::Input::Harbor

This is applied to inputs of type 'harbor'.  It describes an input which
receives connections from icecast source clients as a server and is typically
used for live streams of radio shows from remote sources.

=head3 method kick

    method kick ( --> Bool)

Attempt to kick (disconnect) the current connected client, returning a Bool to
indicate success.  


=head2 Audio::Liquidsoap::Playlist

    class Audio::Liquidsoap::Playlist does Audio::Liquidsoap::Item

A playlist provides a list of files or URIs as a source and may be
a local directory, a text file, xspf, .m3u or other type of
playlist format understood by liquidsoap.

=head3 attribute name

The name of the playlist.

=head3 attribute client

The shared L<Audio::Liquidsoap::Client>

=head3 method next

    method next ()

Returns a list of the next uris or filenames available from
the playlist, in the case of a large playlist or directory
this may only be ten or so.

=head3 method reload

    method reload ()

This will cause the playlist to be reloaded to reflect
any changes, it should not affect any currently playing
track.

=head3 method uri

    method uri ( --> Str)

By default this will reflect the uri that the playlist was
configured with in the liquidsoap script.  It can be set
(it is a read/write method) to change the source of the
playlist, but as of the latest version of liquidsoap I
have tested with it doesn't appear to actual change even
though it will start loading files from the new location.

=head2 Audio::Liquidsoap::Client

This is the common client that provides the connection
to the liquidsoap command server.

=head3 attribute port

The port on which to connect, the default is 1234.

=head3 attribute host

The host on which to connect.  The default is localhost.

=head3 method socket

    method socket ( --> Audio::Liquidsoap::Client::LiquidSock)

This is the actual socket that is used to perform the connection
it is typically not kept open between commands.

=head3 method command

    method command (Str $command, *@args)

Sends the command to the liquidsoap instance, the command should be
qualified with the namespace, any arguments will be supplied as is
separated by spaces.

The command method provided by the L<Audio::Liquidsoap::Item> role
takes care of providing the namespace for the object.

=end pod


class Audio::Liquidsoap:ver<0.0.3>:auth<github:jonathanstowe> {

    class X::NoServer is Exception {
        has $.port;
        has $.host;
        has $.error;
        method message() {
            "Cannot connect on { $!host }:{ $!port } : { $!error }";
        }
    }

    class X::Command is Exception {
        has $.error is required;

        method message() {
            my $e = $!error.subst(/'ERROR: '/,'');
            "Got error from server : '$e'";
        }

    }

    sub check-liquidsoap(Int $port = 1234, Str $host = 'localhost') returns Bool is export {
        my $rc = True;
        CATCH {
            when X::NoServer {
               return False; 
            }
        }

        $rc = Audio::Liquidsoap.new(:$port, :$host).version ?? True !! False;

        $rc;
    }

    class Client {
        has Int $.port  = 1234;
        has Str $.host  = 'localhost';

        my role LiquidSock {
            has Bool $.closed;
            method opened() returns Bool {
                !$!closed;
            }
            method close() returns Bool {
                if self.opened {
                    self.print: "quit\r\n";
                    $!closed = True;
                    nextsame;
                }
            }
        }

        has LiquidSock $!socket;

        method socket() returns LiquidSock handles <recv print close> {
            CATCH {
                default {
                    X::NoServer.new(host => $!host, port => $!port, error => $_.message).throw;
                }
            }

            if not ( $!socket.defined && $!socket.opened) {
                $!socket = IO::Socket::INET.new(host => $!host, port => $!port) but LiquidSock;
            }
            $!socket;
        }

        method command(Str $command, *@args) {
            my Str $out = '';
            self.print: $command ~ "\r\n";
            while my $l = self.recv {
	            if $l ~~ /^^END\r\n/ {
		            last;
	            }
                $out ~= $l;
            }
            self.close;
            if $out ~~ /^^ERROR:/ {
                X::Command.new(error => $out).throw;
            }
            $out;
        }
    }

    has Client $.client;
    has Int $.port = 1234;
    has Str $.host = 'localhost';

    method command(Str $command, *@args) {
        if not $!client.defined {
            $!client = Client.new(host => $!host, port => $!port);
        }
        $!client.command($command, @args);
    }

    method uptime() returns Duration {
        multi sub get-secs(Str $s) returns Duration {
	        my regex uptime {
		        $<day>=[\d+]d\s+$<hour>=[\d+]h\s+$<minute>=[\d+]m\s+$<second>=[\d+]s
	        }
	
	        if $s ~~ /<uptime>/ {
		        get-secs($/<uptime>);
	        }
	        else {
		        fail "Incorrect format";
	        }
        }

        multi sub get-secs(Match $s) returns Duration {
	        my $secs = ($s<day>.Int * 86400) + ($s<hour>.Int * 3600) + ( $s<minute>.Int * 60) + $s<second>.Int;
	        Duration.new($secs);	
        }

        my $u = self.command("uptime");
        get-secs($u);
    }

    method version() returns Version {
        my $v = self.command("version");
        Version.new($v.split(/\s+/)[1]);
    }

    method list() {
        my $list = self.command('list');
        $list.lines;
    }

    has %!vars;

    method get-vars() {
        my $vars = self.command("var.list");
        my %vars;
        for $vars.lines -> $var {
            my ( $name, $type ) = $var.split(/\s+\:\s+/);
            %vars{$name} = do given $type {
                when 'bool' {
                    Bool
                }
                when 'string' {
                    Str
                }
                when 'float' {
                    Numeric
                }
                default {
                    die "unrecognised type '$_' found in vars";
                }
            }


        }
        %vars;
    }


    class X::NoVar is Exception {
        has $.name is required;
        method message() returns Str {
            "Variable '{ $!name }' does not exist";
        }
    }

    multi sub get-val($val, Bool) returns Bool {
        $val eq 'true';
    }

    multi sub get-val($val, Numeric) returns Rat {
        Rat($val);
    }

    multi sub get-val($val, Str) returns Str {
        $val.subst('"', '', :g);
    }

    
    method get-var(Str $name) {
        if not %!vars.keys {
            %!vars = self.get-vars();
        }

        if not %!vars{$name}:exists {
            X::NoVar.throw(name => $name).throw;
        }

        my $val = self.command("var.get $name");
        get-val($val, %!vars{$name});
    }

    multi sub set-val(Bool $val, Bool) returns Str {
        $val.Str.lc;
    }

    multi sub set-val(Numeric $val, Numeric) {
        $val.Str;
    }
    multi sub set-val(Str() $val, Str) {
        '"' ~ $val ~ '"';
    }

    method set-var(Str $name, $val) {
        if not %!vars.keys {
            %!vars = self.get-vars();
        }

        if not %!vars{$name}:exists {
            X::NoVar.throw(name => $name).throw;
        }

        my $out-val = set-val($val, %!vars{$name});

        my $ret = self.command("var.set $name = $out-val");
        if $ret ~~ /"Variable $name set"/ {
            True;
        }
        else {
            False;
        }
    }


    my role SimpleCommand[Str $command] {
        method CALL-ME($self) {
            $self.command($command);
        }
    }

    my role SimpleCommand[Str $command, $check] {
        method CALL-ME($self) {
            $self.command($command) eq $check;
        }
    }

    my role SimpleCommand[Str $command, &after ] {
        method CALL-ME($self) {
            after($self.command($command));
        }
    }

    multi sub trait_mod:<is> (Method $m, Str :$command!) {
        $m does SimpleCommand[$command];
    }

    multi sub trait_mod:<is> (Method $m, :$command! (Str $cmd, Str $check)) {
        $m does SimpleCommand[$cmd, $check];
    }

    multi sub trait_mod:<is> (Method $m, :$command! (Str $cmd, &after)) {
        $m does SimpleCommand[$cmd, &after];
    }

    my role Item {
        has Str $.name;
        has Client $.client;

        method command(Str $command, *@args) {
            my $full-command = "{$!name}.$command";
            if @args.elems {
                $full-command ~= ' ' ~ @args.join(' ');
            }
            $!client.command($full-command);
        }
    }

    sub rids-from-list(Str $rids) {
        $rids.comb(/\d+/).map({Int($_)});
    }

    class Metadata {
        has Str $.title;
        has Str $.artist;
        has Str $.decoder;
        has Str $.filename;
        has Str $.initial-uri;
        has Str $.kind;
        has DateTime $.on-air;
        has Int $.rid;
        has Str $.source;
        has Str $.status;
        has Bool $.temporary;

        multi sub meta-value(Str $key, Str:D $value) {
            $value.subst('"', '', :g)
        }

        multi sub meta-value('on-air', Str:D $value) {
            DateTime.new(samewith(Str,$value).trans('/' => '-', ' ' => 'T'))
        }
        multi sub meta-value('temporary', Str:D $value) {
            samewith(Str, $value) eq 'true';
        }
        multi sub meta-value('rid', Str:D $value ) {
            Int(samewith(Str, $value));
        }

        multi sub meta-key(Str $key) {
            $key.subst('_', '-');
        }
        
        sub get-metadata-pair(Str $line) {
            my ( $key, $value ) = $line.split('=',2);
            if $key && $value {
                $key   = meta-key($key);
                $value = meta-value($key, $value);
                $key, $value;
            }
        }

        multi method new(:$metadata!) {
            my %meta;
            for $metadata.lines -> $line {
                # Moved the awful code to a subroutine
                if my ( $key, $value) = get-metadata-pair($line) {
                    if $key {
                        %meta{$key} = $value;
                    }
                }
            }
            samewith(|%meta);
        }
    }

    class Request does Item {
        =begin note
        | request.alive
        | request.all
        | request.metadata <rid>
        | request.on_air
        | request.resolving
        | request.trace <rid>
        =end note

        method alive()     is command('alive', &rids-from-list)     { * }

        method all()       is command('all', &rids-from-list)       { * }

        method on-air()    is command('on_air', &rids-from-list)    { * }

        method resolving() is command('resolving', &rids-from-list) { * }

        class TraceItem {
            has Int      $.rid;
            has DateTime $.when;
            has Str      $.what;
        }

        method trace(Int() $rid) {
            my @trace;
            for self.command('trace', $rid).lines -> $line {
                if $line ~~ /^^\[$<when>=(.+?)\]\s+$<that>=(.+)$/ {
                    my $what = ~$/<that>;
                    my $dt = DateTime.new((~$/<when>).trans('/' => '-', ' ' => 'T'));
                    @trace.append: TraceItem.new(:$rid, when => $dt, what => $what);
                }
            }
            @trace;
        }

        method metadata(Int() $rid) returns Metadata {
            my $metadata = self.command('metadata', $rid);
            Metadata.new(:$metadata);
        }
    }

    has Request $!requests; 

    method requests() returns Request {
        if not $!requests.defined {
            $!requests = Request.new(name => 'request', client => $!client);
        }
        $!requests;
    }

    class Queue does Item {
        =begin note
        | incoming.consider <rid>
        | incoming.ignore <rid>
        | incoming.primary_queue
        | incoming.push <uri>
        | incoming.queue
        | incoming.secondary_queue
        =end note


        method push(Str $uri) returns Int {
            my $rid = self.command('push',$uri);
            $rid.defined ?? Int($rid) !! Int;
        }

        method consider(Int() $rid) {
            self.command('consider', $rid) eq 'OK';
        }

        method ignore(Int() $rid) {
            self.command('ignore', $rid) eq 'OK';
        }

        method queue() is command('queue', &rids-from-list) { * }

        method primary-queue() is command('primary_queue', &rids-from-list) { * }

        method secondary-queue() is command('secondary_queue', &rids-from-list) { * }

    }

    method queues() {
        if not %!queues.keys.elems {
            self!get-items();
        }
        %!queues;
    }



    class Output does Item {
        has Str $.type;
        =begin note
        | dummy-output.autostart
        | dummy-output.metadata
        | dummy-output.remaining
        | dummy-output.skip
        | dummy-output.start
        | dummy-output.status
        | dummy-output.stop
        =end note


        method start() is command('start') { * }
        method stop()  is command('stop') { * }
        method status() is command('status') { * }
        method skip() is command('skip') { * }
        method autostart() is rw returns Bool {
            my $client  = $!client;
            my $name    = $!name;
            Proxy.new(
                FETCH   =>  method () returns Bool {
                    $client.command("$name.autostart") eq 'on';
                },
                STORE   =>  method (Bool $val) returns Bool {
                    my $on-off = $val ?? 'on' !! 'off';
                    $client.command("$name.autostart $on-off") eq 'on';
                }
            );
        }

        sub get-remaining(Str $r) returns Duration {
            CATCH {
                default {
                    return Duration.new(Rat(0));
                }
            }
            Duration.new(Rat($r // '0'));
        }

        method remaining() returns Duration is command('remaining', &get-remaining) { * }


        method !metadata() is command('metadata') { * }

        method metadata() {
            my @metas;
            for self!metadata.split(/^^'--- '\d+' ---'\s*$$/,:skip-empty) -> $metadata {
                @metas.append: Metadata.new(:$metadata);
            }
            @metas.sort(-> $v { $v.rid });
        }
    }

    method outputs() {
        if not %!outputs.keys.elems {
            self!get-items();
        }
        %!outputs;
    }

    class Input does Item {
        has Str $.type;
        role Http {

            method start() is command('start', 'Done') { * }

            method uri() returns Str is rw {
                my $self = self;
                Proxy.new(
                    FETCH => method () {
                        $self.command('url');
                    },
                    STORE => method (Str() $url) {
                        $self.command('url', $url);
                    }
                );
            }

        }
        role Harbor {
            method kick() returns Str is command('kick', 'Done') { * }
        }

        =begin note
         "http relay"
         | relay-source.buffer_length
         | relay-source.start
         | relay-source.status
         | relay-source.stop
         | relay-source.url [url]
         "harbor"
         | live-source.buffer_length
         | live-source.kick
         | live-source.status
         | live-source.stop
        =end note

        # TODO: make pluggable
        my %type-role = harbor => Harbor, http => Http;

        multi method new(Str :$name, Client :$client, Str :$type ) {
            my $self = self.bless(:$name, :$client, :$type);
            if %type-role{$type}:exists {
                $self does %type-role{$type};
            }
            $self;
        }

        method buffer-length() is command('buffer_length', -> Str $l { Rat($l) }) { * }

        method stop() is command('stop', 'Done') { * }

        method status() returns Str is command('status') { * }

    }

    has Input %!inputs;

    method inputs() {
        if not %!inputs.keys.elems {
            self!get-items();
        }
        %!inputs;
    }

    class Playlist does Item {
        =begin note
        | default-playlist.next
        | default-playlist.reload
        | default-playlist.uri [<URI>]
        =end note

        method next() is command('next', -> $l { $l.lines} ) { * }

        method reload() is command('reload', 'OK') { * }

        method uri() returns Str is rw {
            my $client = $!client;
            my $command = $!name ~ '.uri';
            Proxy.new(
                FETCH => method () {
                    $client.command($command);
                },
                STORE => method (Str() $uri) {
                    $client.command("$command $uri");
                }
            );
        }
    }

    method playlists() {
        if not %!playlists.keys.elems {
            self!get-items();
        }
        %!playlists;
    }

    method !get-items() {
        for self.list -> $item-line {
            my ($name, $type)  = $item-line.split(/\s+\:\s+/);
            given $type {
                when 'queue' {
                    %!queues{$name} = Queue.new(name => $name, client => $!client);

                }
                when 'playlist' {
                    %!playlists{$name} = Playlist.new(name => $name, client => $!client);

                }
                when /^output/ {
                    my $st = $_.split('.')[1];
                    %!outputs{$name} = Output.new(name => $name, client => $!client, type => $st);
                }
                when /^input/ {
                    my $st = $_.split('.')[1];
                    %!inputs{$name} = Input.new(name => $name, client => $!client, type => $st);
                }
                when /variables/ {
                    # do nothing but want to know when we really get one we don't know about
                }
                default {
                    warn "unknown item type '$type'";
                }
            }

        }
    }

    has Queue       %!queues;
    has Output      %!outputs;
    has Playlist    %!playlists;
}

# vim: expandtab shiftwidth=4 ft=perl6
