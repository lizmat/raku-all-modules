use v6;

=begin pod

=head1 NAME

Audio::Libshout - binding to the xiph.org libshout icecast source client

=head1 SYNOPSIS

=begin code

    use Audio::Libshout;

    my $shout = Audio::Libshout.new(password => 'hackme', mount => '/foo', format => Audio::Libshout::Format::MP3);
    my $fh = @*ARGS[0].IO.open(:bin);
    my $channel = $shout.send-channel;

    while not $fh.eof {
	    my $buf = $fh.read(4096);
	    $channel.send($buf);
    }

    $fh.close;
    $channel.close;
    $shout.close;

=end code

See also the files in the C<examples> directory

=head1 DESCRIPTION

This provides a source client to stream to an icecast server.  It can
stream Ogg/Vorbis or MP3 data but doesn't provide any transcoding so the
data will need to be provided from an appropriate source in the required
encoding. This has been developed against version 2.2.2 of libshout,
it is possible later versions may provide support for other encodings.

The API is somewhat simplified in comparison to libshout but provides
an asynchronous mechanism whereby data can be fed as quickly as it is
obtained to a worker thread via a channel so the client doesn't have
to worry about the timing and synchronisation issues, though the lower
level send and sync methods are available if your application requires
a different scheme.

In testing this proved quite capable of streaming a 320kb/s MP3 read from
a file to an icecast server on the local network, though of course network
conditions may limit the rate that will work well to remote servers.

The "examples" directory in the distribution contains a simple streaming
source client that will allow you to send an Ogg or MP3 file to an
icecast server.

If you're curious the first thing that I streamed using this library was

https://www.mixcloud.com/mikestern-awakening/mike-stern-guest-mix-for-technotic-eire-radio-show/

Mike's a great DJ, great DJs and producers make making software
worthwhile :)

=head1 METHODS

=head2 method new

    method new(*%params) returns Audio::Libshout

The object constructor can be passed any of the parameters described in
L<STREAM PARAMETERS>.  It may throw an L<X::ShoutError> if there was a
problem initialising the library or setting any of the parameters.

The L<Audio::Libshout> object returned will be initialised but not
connected to the server, the connection should be made before any data
is sent to the server.

=head2 method open

    method open()

If the stream is not already connected this will open the stream so
that data can be sent.  The C<host>, C<port>, C<user> and C<password>
and other parameters that may be required by the protocol must be set
before calling C<open>.  If a connection cannot be made to the server or
the server refuses the connection (e.g. due to an authentication failure,)
a L<X::ShoutError> will be thrown.

This will be called for you the first time that C<send> is called or
the first data is sent to the C<send-channel> however you may wish to
call it early in order to detect and rectify any problems.

=head2 method close

    method close()

This will close the connection to the server.  It will wait for the worker
thread that is started by C<send-channel> to complete, which will not
happen until the L<Channel> is closed so you should always call C<close>
on the channel to indicate that no more data will be sent.

=head2 method send

    multi method send(Buf $buf)
    multi method send(CArray[uint8], Int $bytes);
    multi method send(RawEncode $raw);

This will send the L<Buf> of unsigned chars (L<uint8>,) to the
server. The buffer must contain data encoded as per that set for C<format>
(i.e. either C<Ogg> or C<MP3> ) If there is a problem sending the data to
the server then a L<X::ShoutError> will be thrown.  If C<open> has not
already been called it will be called for you and this may also throw an
exception. The data will be sent immediately so C<sync> should be called
between each attempt to send or an exception may be thrown indicating
that the server is busy.

The second multi variant is intended to make interoperation with other
libraries which may return encoded data in a C<CArray>.  The third
is similar but accepts an C<Array> of two elements the first being
a C<CArray[uint8]> and the second an C<Int> which is the number of
bytes in the array, this reflects the return value of the C<encode>
methods of L<Audio::Encode::LameMP3> with the C<:raw> adverb. This
is intended to reduce the marshalling required when there is no
need to have the data in perl space.

If you don't want to be concerned with the synchronisation issues then you
should consider the asynchronous interface provided by C<send-channel>.


=head2 method sync

    method sync()

This will block the thread of execution until the server is ready to
accept new data.  It should be called between each call to C<send> in
order to maintain the rate of data transfer correctly.  A C<send> that
is made without a preceding C<sync> may throw an exception indicating
that the server is busy.

If you don't want to be concerned with the synchronisation issues then you
should consider the asynchronous interface provided by C<send-channel>.

=head2 method send-channel
    
    multi method send-channel() returns Channel
    multi method send-channel(Channel $channel) returns Channel

This provides an asynchronous mechanism that allows a client to send
data to a L<Channel> as it becomes available, being processed by a
helper thread that will take care of the synchronisation.  This should
be considered the preferred interface for most applications.

If C<open> has not already been called then it will be done for you the
first time that data is received on the L<Channel>, as with C<open> an
exception will be thrown if a connection cannot be made or the server
refuses the connection.

As with C<send> the data sent to the L<Channel> should be a L<Buf>
of unsigned chars (L<uint8>). If data of another type is sent on the
channel then an exception will be thrown in the worker thread. The data
can also be Array of two elements: a C<CArray[uint8]> and an C<Int> that
is the number of bytes in that C<CArray> as described under C<send> above.

This can be provided with an existing L<Channel> that may be useful if
the data originates from another asynchronous source for example.

The worker thread will be started immediately that this method is called
and will remain active until the channel is closed, consequently a
subsequent call to C<close> will wait until the thread is finished to
allow all the sent data to be transmitted to the server.

The "streamfile" program in the repository provides an example of the
use of this interface.

=head2 add-metadata

   multi method add-metadata(Str $key, Str $value)
   multi method add-metadata(*%metas)

This provides a means to set the metadata on the stream, it only works
for streams of format C<MP3>. The exact meaning of any particular metadata
item is specific to the client of the stream.

The metadata items are added to or updated in a private metadata
structure, that can be applied to the stream with C<set-metadata>, for
convenience if the metadata is supplied in the second form (i.e like
named arguments,) this will be done for you.

This may throw a L<X::ShoutError> if the metadata structure is invalid.

=head2 set-metadata

    method set-metadata()

This will send the metadata as added or updated by C<add-metadata> to
the connected stream. This will only work if the format of the stream
is C<MP3>.

It will throw a L<X::ShoutError> if an error is encountered while setting
the metadata.

=head2 libshout-version

This will return a L<Version> object that represents the version of the
C<libshout> that is being used.

=head1 STREAM PARAMETERS

These can all be supplied to the constructor as named arguments or set
as attributes on a new object, some provide sensible defaults which
are noted and some are required and must be set before the stream is
opened. Setting a parameter that doesn't make sense given the state of
the stream or already set parameters will result in a L<X::ShoutError>
being thrown.

=head2 host 

The hostname or IP address of the streaming server.  The default is 'localhost'.

=head2 port 

The port number on which the server is listening.  The default is 8000

=head2 user 

The username that is used to authenticate against the server, the default is 'source'.
If the C<protocol> is set to C<ICY> then setting this makes no sense as 'source' is
always used.

=head2 password 

The password that is used to authenticate with the server.  There is no default and this
must be provided before connecting.

=head2 protocol 

A value of the C<enum> L<Audio::Libshout::Protocol> indicating which protocol should be used
to communicate with the server:

=item HTTP

This is the Icecast v2 protocol and the default, this should be used unless there is a 
compelling reason to do otherwise.

=item XAUDIOCAST

The protocol used by version 1 of Icecast.

=item ICY

The Shoutcast protocol. If this is used then there are certain constraints on other parameters,
it should only be used if you are using an actual Shoutcast server.

=head2 format 

The encoding format that is to be sent as a value of the C<enum> L<Audio::Libshout::Format> - the
default is C<Ogg>.  No transcoding is done so the data to be sent to the server must be in the
configured format - the result of setting a different format to the actual format of the data is that
you will get an unreadable stream. Later versions of C<libshout> might provide for further formats.

=item MP3

=item Ogg

=head2 mount 

The "mount point" (i.e. the path part ) on the server that represents this stream. There is no
default. The C<ICY> protocol does not support setting this. On setting this will be "normalised"
with a leading '/' (e.g. setting "stream" will return "/stream".)

=head2 dumpfile 

This can be set to cause an archive of the stream to be made on the server with the provided name.
The server may not support this (or may configured to allow it.)  The resulting file will be at
least as large as the streamed data and if the server runs out of disk space it may interrupt the
stream, so think carefully before using this.

=head2 agent 

This is the UserAgent header that is sent for the C<HTTP> protocol.  The default is "libshout/$version".

=head2 public 

This is a L<Bool> that indicates whether the server should list the stream in any directory services that
it has configured. The default is C<False>.


=head2 name 

The stream name that should be used in a directory listing. This may also be passed on to connected clients.
There is no default.

=head2 url 

The stream URL that should be used in a directory listing. This may also be passed on to connected clients.
There is no default.

=head2 genre 

The genre of the stream that should be used in a directory listing. This may also be passed on to connected clients.
There is no default.

=head2 description

A description of the stream that should be used in a directory listing. This may also be passed on to connected clients.
There is no default.

=end pod

class Audio::Libshout:ver<0.0.8>:auth<github:jonathanstowe> {
    use NativeCall;
    use AccessorFacade;

    # encapsulate (bytes, count) in a type safe way
    subset RawEncode of Array where  ($_.elems == 2 ) && ($_[0] ~~ CArray) && ($_[1] ~~ Int);

    enum Error ( Success => 0 , Insane => -1 , Noconnect => -2 , Nologin => -3 , Socket => -4 , Malloc => -5, Meta => -6, Connected => -7, Unconnected => -8, Unsupported => -9, Busy => -10 );
    enum Format ( Ogg => 0, MP3 => 1 );
    enum Protocol ( HTTP => 0, XAUDIOCAST => 1, ICY => 2);

    class X::ShoutError is Exception {
        has Error $.error;
        has Str $.what = "unknown operation";

        method message() {
            my $message = do given $!error {
                                when Insane {
                                    "Not a valid Shout object or missing parameters";
                                }
                                when Noconnect {
                                    "A connection to the server could not be established."
                                }
                                when Nologin {
                                    "The server refused login, probably because authentication failed.";
                                }
                                when Socket {
                                    "An error occured while talking to the server.";
                                }
                                when Malloc {
                                    "There wasn't enough memory to complete the operation.";
                                }
                                when Meta {
                                    "The server returned an error while setting metadata.";
                                }
                                when Connected {
                                    "The connection has already been opened."
                                }
                                when Unconnected {
                                    "The Shout object is not currently connected";
                                }
                                when Unsupported {
                                    "The combination of parameters is not supported for this operation";
                                }
                                when Busy {
                                    "The connection is busy and could not perform the operation.";
                                }
                                default {
                                    "Unknown issue or not an error";
                                }

                            }
            $!what ~ ' : ' ~ $message;
        }
    }

    class Metadata is repr('CPointer') {
        sub shout_metadata_new() returns Metadata is native('shout',v3) { * }

        method new() {
            shout_metadata_new();
        }

        sub shout_metadata_free(Metadata) is native('shout',v3) { * }

        method DESTROY() {
            shout_metadata_free(self);
        }

        sub shout_metadata_add(Metadata, Str, Str ) returns int32 is native('shout',v3) { * }

        method add(Str $key is copy, Str $value is copy) returns Error {
            explicitly-manage($key);
            explicitly-manage($value);
            my $rc = shout_metadata_add(self, $key, $value);
            Error($rc);
        }

    }

    class Shout is repr('CPointer') {

        sub shout_new() returns Shout is native('shout',v3) { * }

        method new(Shout:U: *%attribs) returns Shout {
            my $shout = shout_new();

            for %attribs.kv -> $attrib, $value {
                if $shout.can($attrib) {
                    $shout."$attrib"() = $value;
                }
            }
            $shout;
        }

        sub shout_free(Shout) returns int32 is native('shout',v3) { * }

        submethod DESTROY() {
            shout_free(self);
        }

        sub shout_open(Shout) returns int32 is native('shout',v3) { * }

        method open() returns Error {
            my $rc = shout_open(self);
            Error($rc);
        }

        sub shout_close(Shout) returns int32 is native('shout',v3) { * }

        method close() returns Error {
            my $rc = shout_close(self);
            Error($rc);
        }
        
        sub shout_send(Shout, CArray[uint8], int32) returns int32 is native('shout',v3) { * }

        proto method send(|c) { * }
        multi method send(CArray $buf, Int $elems) returns Error {
            my $rc = shout_send(self, $buf, $elems);
            Error($rc);
        }

        multi method send(Buf $buf) returns Error {
            my $carray = CArray[uint8].new;
            $carray[$_] = $buf[$_] for ^($buf.elems);
            self.send($carray, $buf.elems);
        }

        sub shout_sync(Shout) is native('shout',v3) { * }

        method sync() {
            shout_sync(self);
        }

        my sub manage(Shout $self, Str $value is copy) {
            explicitly-manage($value);
            $value;
        }

        my sub check(Shout $self, Int $rc ) {
            given Error($rc) {
                when Success {
                }
                default {
                    X::ShoutError.new(error => $_, what => "Setting parameter").throw;
                }
            }

        }

        # "attributes"
        #
        sub shout_set_host(Shout, Str) returns int32 is native('shout',v3) { * }
        sub shout_get_host(Shout) returns Str is native('shout',v3) { * }

        method host() returns Str is rw is accessor-facade(&shout_get_host, &shout_set_host, &manage, &check) { }

        sub shout_set_port(Shout, int32) returns int32 is native('shout',v3) { * }
        sub shout_get_port(Shout) returns int32 is native('shout',v3) { * }

        method port() returns Int is rw is accessor-facade(&shout_get_port, &shout_set_port, Code, &check) { }

        sub shout_set_user(Shout, Str) returns int32 is native('shout',v3) { * }
        sub shout_get_user(Shout) returns Str is native('shout',v3) { * }

        method user() returns Str is rw is accessor-facade(&shout_get_user, &shout_set_user, &manage, &check) { }

        sub shout_set_password(Shout, Str) returns int32 is native('shout',v3) { * }
        sub shout_get_password(Shout) returns Str is native('shout',v3) { * }

        method password() returns Str is rw is accessor-facade(&shout_get_password, &shout_set_password, &manage, &check) { }

        sub shout_get_protocol(Shout) returns int32 is native('shout',v3) { * }
        sub shout_set_protocol(Shout, int32) returns int32 is native('shout',v3) { * }

        method protocol() returns Protocol is rw is accessor-facade(&shout_get_protocol, &shout_set_protocol, Code, &check) { }

        sub shout_get_format(Shout) returns int32 is native('shout',v3) { * }
        sub shout_set_format(Shout, int32) returns int32 is native('shout',v3) { * }

        method format() returns Format is rw is accessor-facade(&shout_get_format, &shout_set_format, Code, &check) { }

        sub shout_get_mount(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_mount(Shout, Str) returns int32 is native('shout',v3) { * }

        method mount() returns Str is rw is accessor-facade(&shout_get_mount, &shout_set_mount, &manage, &check) { }

        sub shout_get_dumpfile(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_dumpfile(Shout, Str ) returns int32 is native('shout',v3) { * }

        method dumpfile() returns Str is rw is accessor-facade(&shout_get_dumpfile, &shout_set_dumpfile, &manage, &check ) { }

        sub shout_get_agent(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_agent(Shout, Str) returns int32 is native('shout',v3) { * }

        method agent() returns Str is rw is accessor-facade(&shout_get_agent, &shout_set_agent, &manage, &check) { }

        # Directory parameters
        sub shout_get_public(Shout) returns int32 is native('shout',v3) { * }
        sub shout_set_public(Shout, int32) returns int32 is native('shout',v3) { * }

        method public returns Bool is rw is accessor-facade(&shout_get_public, &shout_set_public, Code, &check) { }

        sub shout_get_name(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_name(Shout, Str) returns int32 is native('shout',v3) { * }

        method name() returns Str is rw is accessor-facade(&shout_get_name, &shout_set_name, &manage, &check) { }

        sub shout_get_url(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_url(Shout, Str) returns int32 is native('shout',v3) { * }

        method url() returns Str is rw is accessor-facade(&shout_get_url, &shout_set_url, &manage, &check) { }

        sub shout_get_genre(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_genre(Shout, Str) returns int32 is native('shout',v3) { * }

        method genre() returns Str is rw is accessor-facade(&shout_get_genre, &shout_set_genre, &manage, &check) { }

        sub shout_get_description(Shout) returns Str is native('shout',v3) { * }
        sub shout_set_description(Shout, Str) returns int32 is native('shout',v3) { * }

        method description() returns Str is rw is accessor-facade(&shout_get_description, &shout_set_description, &manage, &check) { }

        # Not making a method for these quite yet.
        sub shout_get_audio_info(Shout, Str) returns Str is native('shout',v3) { * }
        sub shout_set_audio_info(Shout, Str, Str) returns Str is native('shout',v3) { * }

        # Set the metadata on this instance.

        sub shout_set_metadata(Shout, Metadata) returns int32 is native('shout',v3) { * }

        method set-metadata(Metadata $meta) returns Error {
            my $rc = shout_set_metadata(self, $meta);
            Error($rc);
        }

        sub shout_get_error(Shout) returns Str is native('shout',v3) { * };

        method last-error() returns Str {
            shout_get_error(self);
        }

        sub shout_get_errno(Shout) returns int32 is native('shout',v3) { * };

        method last-error-number() returns Error {
            my $rc = shout_get_errno(self);
            Error($rc);
        }
    }

    class Initialiser {
        has Int $!initialisers = 0;

        sub shout_init() is native('shout',v3) { * }

        method init() {
            if $!initialisers == 0 {
                shout_init();
            }
            ++$!initialisers;
        }

        sub shout_shutdown() is native('shout',v3) { * }

        method shutdown() {
            --$!initialisers;
            if $!initialisers == 0 {
                shout_shutdown();
            }
        }
    }


    my $initialiser = Initialiser.new;

    has Shout $!shout handles <host port user password protocol format mount dumpfile agent public name url genre description>;
    has Metadata $!metadata;

    has Bool $!opened = False;

    has Promise $!helper-promise;

    method open() {
        if not $!opened {
            my $rc = $!shout.open();
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "opening stream").throw;
            }
            $!opened = True;
        }
    }

    proto method send(|c) { * }
    multi method send(Buf $buff) {
        if not $!opened {
            self.open()
        }
        my $rc = $!shout.send($buff);
        if $rc !~~ Success {
            X::ShoutError.new(error => $rc, what => "sending data").throw;
        }
    }

    multi method send(CArray $buff, Int $bytes) {
        if not $!opened {
            self.open()
        }
        my $rc = $!shout.send($buff, $bytes);
        if $rc !~~ Success {
            X::ShoutError.new(error => $rc, what => "sending data").throw;
        }
    }

    multi method send(RawEncode $raw) {
        self.send($raw[0], $raw[1]);
    }

    proto method send-channel(|c) { * }

    multi method send-channel(Audio::Libshout $self:) returns Channel {
        my $channel = Channel.new;
        $self.send-channel($channel);
    }

    class X::ChannelError is Exception {
        has Exception $.inner;
        method message() {
            "An error occurred in the send-channel : '{ $!inner.message }'";
        }
    }

    multi method send-channel(Audio::Libshout $self: Channel $channel) returns Channel {
        $!helper-promise = start {
            react {
                whenever $channel -> $item {
                    CATCH {
                        default {
                            $self.close;
                            X::ChannelError.new(inner => $_).throw;
                        }
                    }
                    $self.send($item);
                    $self.sync;
                }
            }
        }
        $channel;
    }

    method sync() {
        if $!opened {
            $!shout.sync();
        }
    }

    method close() {
        if $!helper-promise.defined {
            await $!helper-promise;
        }
        if $!opened {
            my $rc = $!shout.close();
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "closing stream").throw;
            }
            $!opened = False;
        }
    }

    proto method add-metadata(|c) { * }

    multi method add-metadata(Str $key, Str $value) {
        my $rc = $!metadata.add($key, $value);
        if $rc !~~ Success {
            X::ShoutError.new(error => $rc, what => "adding metadata");
        }
    }

    multi method add-metadata(*%metas) {
        for %metas.kv -> $key, $value {
            self.add-metadata($key, $value);
        }
        self.set-metadata();
    }

    method set-metadata() {
        if self.format ~~ MP3 {
            my $rc = $!shout.set-metadata($!metadata);
            if $rc !~~ Success {
                X::ShoutError.new(error => $rc, what => "setting metadata");
            }
        }
    }


    sub shout_version(int32, int32, int32) returns Str is native('shout',v3) { * }
    method libshout-version() returns Version {
        my int32 $major;
        my int32 $minor;
        my int32 $patch;
        my $v = shout_version($major, $minor, $patch);
        Version.new($v);
    }

    multi submethod BUILD(*%attribs) {
        if not $initialiser.defined {
            $initialiser = Initialiser.new;
        }
        $initialiser.init();
        $!shout = Shout.new(|%attribs);
        $!metadata = Metadata.new;
    }

    submethod DESTROY() {
        $!shout = Shout;
        $!metadata = Metadata;
        $initialiser.shutdown();
    }

}

# vim: expandtab shiftwidth=4 ft=perl6
